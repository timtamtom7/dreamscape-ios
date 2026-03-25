import Foundation
import SwiftUI

// MARK: - Family Dream Sharing

struct FamilyDreamProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarEmoji: String
    var sharedDreamIds: [UUID]
    var joinedAt: Date

    init(id: UUID = UUID(), name: String, avatarEmoji: String = "👤", sharedDreamIds: [UUID] = [], joinedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.sharedDreamIds = sharedDreamIds
        self.joinedAt = joinedAt
    }
}

struct SharedDreamConnection: Identifiable, Codable {
    let id: UUID
    let dreamId: UUID
    let partnerId: UUID
    let sharedAt: Date
    var notes: String?

    init(id: UUID = UUID(), dreamId: UUID, partnerId: UUID, sharedAt: Date = Date(), notes: String? = nil) {
        self.id = id
        self.dreamId = dreamId
        self.partnerId = partnerId
        self.sharedAt = sharedAt
        self.notes = notes
    }
}

@MainActor
final class FamilyShareStore: ObservableObject {
    static let shared = FamilyShareStore()

    private let profilesKey = "family_profiles"
    private let connectionsKey = "shared_connections"

    @Published var familyProfiles: [FamilyDreamProfile] = []
    @Published var sharedConnections: [SharedDreamConnection] = []

    init() {
        load()
    }

    func addProfile(_ profile: FamilyDreamProfile) {
        familyProfiles.append(profile)
        save()
    }

    func removeProfile(id: UUID) {
        familyProfiles.removeAll { $0.id == id }
        sharedConnections.removeAll { $0.partnerId == id }
        save()
    }

    func shareDream(dreamId: UUID, with partnerId: UUID) {
        let connection = SharedDreamConnection(dreamId: dreamId, partnerId: partnerId)
        sharedConnections.append(connection)

        if let index = familyProfiles.firstIndex(where: { $0.id == partnerId }) {
            familyProfiles[index].sharedDreamIds.append(dreamId)
        }
        save()
    }

    func sharedDreams(with partnerId: UUID) -> [UUID] {
        sharedConnections.filter { $0.partnerId == partnerId }.map { $0.dreamId }
    }

    func removeShare(connectionId: UUID) {
        if let conn = sharedConnections.first(where: { $0.id == connectionId }) {
            if let index = familyProfiles.firstIndex(where: { $0.id == conn.partnerId }) {
                familyProfiles[index].sharedDreamIds.removeAll { $0 == conn.dreamId }
            }
        }
        sharedConnections.removeAll { $0.id == connectionId }
        save()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([FamilyDreamProfile].self, from: data) {
            familyProfiles = decoded
        }
        if let data = UserDefaults.standard.data(forKey: connectionsKey),
           let decoded = try? JSONDecoder().decode([SharedDreamConnection].self, from: data) {
            sharedConnections = decoded
        }
    }

    private func save() {
        if let profilesData = try? JSONEncoder().encode(familyProfiles) {
            UserDefaults.standard.set(profilesData, forKey: profilesKey)
        }
        if let connData = try? JSONEncoder().encode(sharedConnections) {
            UserDefaults.standard.set(connData, forKey: connectionsKey)
        }
    }
}
