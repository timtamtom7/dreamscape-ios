import Foundation
import CloudKit

@MainActor
final class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var isCloudAvailable = false

    private let container = CKContainer(identifier: "iCloud.com.dreamscape.app")
    private var privateDatabase: CKDatabase?

    private init() {
        checkCloudAvailability()
    }

    private func checkCloudAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isCloudAvailable = (status == .available)
                if let error = error {
                    self?.syncError = error.localizedDescription
                }
            }
        }
    }

    func syncDreams(_ dreams: [Dream]) async throws {
        guard isCloudAvailable else {
            throw CloudSyncError.notAvailable
        }

        await MainActor.run { isSyncing = true }

        do {
            let records = dreams.map { dreamToRecord($0) }
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isSyncing = false
                            self.lastSyncDate = Date()
                        }
                        continuation.resume()
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.isSyncing = false
                            self.syncError = error.localizedDescription
                        }
                        continuation.resume(throwing: error)
                    }
                }

                if let database = container.privateCloudDatabase as CKDatabase? {
                    database.add(operation)
                } else {
                    continuation.resume(throwing: CloudSyncError.databaseUnavailable)
                }
            }
        } catch {
            await MainActor.run {
                isSyncing = false
                syncError = error.localizedDescription
            }
            throw error
        }
    }

    func fetchDreamsFromCloud() async throws -> [Dream] {
        guard isCloudAvailable else {
            throw CloudSyncError.notAvailable
        }

        guard let database = container.privateCloudDatabase as CKDatabase? else {
            throw CloudSyncError.databaseUnavailable
        }

        await MainActor.run { isSyncing = true }

        defer {
            Task { @MainActor in
                isSyncing = false
            }
        }

        let query = CKQuery(recordType: "Dream", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let (results, _) = try await database.records(matching: query)
            var dreams: [Dream] = []

            for (_, result) in results {
                switch result {
                case .success(let record):
                    if let dream = recordToDream(record) {
                        dreams.append(dream)
                    }
                case .failure:
                    continue
                }
            }

            await MainActor.run {
                lastSyncDate = Date()
            }

            return dreams
        } catch {
            await MainActor.run {
                syncError = error.localizedDescription
            }
            throw error
        }
    }

    func deleteDreamFromCloud(_ dream: Dream) async throws {
        guard isCloudAvailable else {
            throw CloudSyncError.notAvailable
        }

        guard let database = container.privateCloudDatabase as CKDatabase? else {
            throw CloudSyncError.databaseUnavailable
        }

        let recordID = CKRecord.ID(recordName: dream.id.uuidString)

        do {
            try await database.deleteRecord(withID: recordID)
        } catch {
            await MainActor.run {
                syncError = error.localizedDescription
            }
            throw error
        }
    }

    private func dreamToRecord(_ dream: Dream) -> CKRecord {
        let recordID = CKRecord.ID(recordName: dream.id.uuidString)
        let record = CKRecord(recordType: "Dream", recordID: recordID)

        record["content"] = dream.content
        record["summary"] = dream.summary
        record["createdAt"] = dream.createdAt
        record["updatedAt"] = dream.updatedAt

        // Encode symbols as JSON data
        if let symbolsData = try? JSONEncoder().encode(dream.symbols) {
            record["symbols"] = symbolsData
        }

        return record
    }

    private func recordToDream(_ record: CKRecord) -> Dream? {
        guard let content = record["content"] as? String,
              let summary = record["summary"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }

        var symbols: [Symbol] = []
        if let symbolsData = record["symbols"] as? Data {
            symbols = (try? JSONDecoder().decode([Symbol].self, from: symbolsData)) ?? []
        }

        return Dream(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            content: content,
            summary: summary,
            symbols: symbols,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

enum CloudSyncError: LocalizedError {
    case notAvailable
    case databaseUnavailable
    case syncFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .databaseUnavailable:
            return "Unable to access iCloud database."
        case .syncFailed:
            return "Failed to sync with iCloud."
        }
    }
}
