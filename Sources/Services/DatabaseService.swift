import Foundation
import SQLite

@MainActor
final class DatabaseService {
    static let shared = DatabaseService()

    private var db: Connection?

    // Tables
    private let dreams = Table("dreams")
    private let symbols = Table("symbols")
    private let dreamSymbols = Table("dream_symbols")

    // Dream columns
    private let dreamId = SQLite.Expression<String>("id")
    private let dreamContent = SQLite.Expression<String>("content")
    private let dreamSummary = SQLite.Expression<String>("summary")
    private let dreamCreatedAt = SQLite.Expression<Date>("created_at")
    private let dreamUpdatedAt = SQLite.Expression<Date>("updated_at")
    // R2: Enhanced dream columns
    private let dreamMood = SQLite.Expression<String?>("mood")
    private let dreamIsLucid = SQLite.Expression<Bool>("is_lucid")
    private let dreamRecurringVariantId = SQLite.Expression<String?>("recurring_variant_id")
    private let dreamAttachedPhotoURL = SQLite.Expression<String?>("attached_photo_url")
    private let dreamEmotionalTags = SQLite.Expression<String>("emotional_tags")

    // Symbol columns
    private let symbolId = SQLite.Expression<String>("id")
    private let symbolName = SQLite.Expression<String>("name")
    private let symbolCategory = SQLite.Expression<String>("category")
    private let symbolFrequency = SQLite.Expression<Int>("frequency")
    private let symbolLastSeen = SQLite.Expression<Date>("last_seen")
    // R2: Enhanced symbol columns
    private let symbolEmotionalTag = SQLite.Expression<String?>("emotional_tag")
    private let symbolRarityScore = SQLite.Expression<Double>("rarity_score")

    // Dream-Symbol junction columns
    private let junctionDreamId = SQLite.Expression<String>("dream_id")
    private let junctionSymbolId = SQLite.Expression<String>("symbol_id")
    private let junctionEmotionalTag = SQLite.Expression<String?>("emotional_tag")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let dbPath = documentsPath.appendingPathComponent("dreamscape.sqlite3")
            db = try Connection(dbPath.path)
            createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() {
        guard let db = db else { return }

        do {
            try db.run(dreams.create(ifNotExists: true) { t in
                t.column(dreamId, primaryKey: true)
                t.column(dreamContent)
                t.column(dreamSummary)
                t.column(dreamCreatedAt)
                t.column(dreamUpdatedAt)
                // R2 columns
                t.column(dreamMood)
                t.column(dreamIsLucid, defaultValue: false)
                t.column(dreamRecurringVariantId)
                t.column(dreamAttachedPhotoURL)
                t.column(dreamEmotionalTags, defaultValue: "")
            })

            try db.run(symbols.create(ifNotExists: true) { t in
                t.column(symbolId, primaryKey: true)
                t.column(symbolName)
                t.column(symbolCategory)
                t.column(symbolFrequency)
                t.column(symbolLastSeen)
                // R2 columns
                t.column(symbolEmotionalTag)
                t.column(symbolRarityScore, defaultValue: 0.5)
            })

            try db.run(dreamSymbols.create(ifNotExists: true) { t in
                t.column(junctionDreamId)
                t.column(junctionSymbolId)
                t.column(junctionEmotionalTag)
                t.primaryKey(junctionDreamId, junctionSymbolId)
            })
        } catch {
            print("Table creation error: \(error)")
        }
    }

    // MARK: - Dream Operations

    func saveDream(_ dream: Dream) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let emotionalTagsString = dream.emotionalTags.joined(separator: ",")

        let insert = dreams.insert(or: .replace,
            dreamId <- dream.id.uuidString,
            dreamContent <- dream.content,
            dreamSummary <- dream.summary,
            dreamCreatedAt <- dream.createdAt,
            dreamUpdatedAt <- dream.updatedAt,
            // R2 fields
            dreamMood <- dream.mood?.rawValue,
            dreamIsLucid <- dream.isLucid,
            dreamRecurringVariantId <- dream.recurringVariantId?.uuidString,
            dreamAttachedPhotoURL <- dream.attachedPhotoURL?.absoluteString,
            dreamEmotionalTags <- emotionalTagsString
        )
        try db.run(insert)

        // Save associated symbols
        for symbol in dream.symbols {
            try saveSymbol(symbol)
            try linkDreamSymbol(dreamId: dream.id, symbolId: symbol.id, emotionalTag: symbol.emotionalTag)
        }
    }

    func fetchAllDreams() throws -> [Dream] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [Dream] = []
        for row in try db.prepare(dreams.order(dreamCreatedAt.desc)) {
            guard let id = UUID(uuidString: row[dreamId]) else { return [] }
            let dreamSymbolsList = try fetchSymbolsForDream(id: id)

            let mood: MoodTag? = row[dreamMood].flatMap { MoodTag(rawValue: $0) }
            let recurringId: UUID? = row[dreamRecurringVariantId].flatMap { UUID(uuidString: $0) }
            let photoURL: URL? = row[dreamAttachedPhotoURL].flatMap { URL(string: $0) }
            let emotionalTags = row[dreamEmotionalTags].split(separator: ",").map(String.init).filter { !$0.isEmpty }

            let dream = Dream(
                id: id,
                content: row[dreamContent],
                summary: row[dreamSummary],
                symbols: dreamSymbolsList,
                createdAt: row[dreamCreatedAt],
                updatedAt: row[dreamUpdatedAt],
                mood: mood,
                isLucid: row[dreamIsLucid],
                recurringVariantId: recurringId,
                attachedPhotoURL: photoURL,
                emotionalTags: emotionalTags
            )
            result.append(dream)
        }
        return result
    }

    func fetchDream(id: UUID) throws -> Dream? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = dreams.filter(dreamId == id.uuidString)
        guard let row = try db.pluck(query) else { return nil }

        let dreamSymbolsList = try fetchSymbolsForDream(id: id)

        let mood: MoodTag? = row[dreamMood].flatMap { MoodTag(rawValue: $0) }
        let recurringId: UUID? = row[dreamRecurringVariantId].flatMap { UUID(uuidString: $0) }
        let photoURL: URL? = row[dreamAttachedPhotoURL].flatMap { URL(string: $0) }
        let emotionalTags = row[dreamEmotionalTags].split(separator: ",").map(String.init).filter { !$0.isEmpty }

        return Dream(
            id: id,
            content: row[dreamContent],
            summary: row[dreamSummary],
            symbols: dreamSymbolsList,
            createdAt: row[dreamCreatedAt],
            updatedAt: row[dreamUpdatedAt],
            mood: mood,
            isLucid: row[dreamIsLucid],
            recurringVariantId: recurringId,
            attachedPhotoURL: photoURL,
            emotionalTags: emotionalTags
        )
    }

    func deleteDream(id: UUID) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let dreamToDelete = dreams.filter(dreamId == id.uuidString)
        try db.run(dreamToDelete.delete())

        // Remove symbol links
        let linksToDelete = dreamSymbols.filter(junctionDreamId == id.uuidString)
        try db.run(linksToDelete.delete())
    }

    // MARK: - Symbol Operations

    func saveSymbol(_ symbol: Symbol) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let insert = symbols.insert(or: .replace,
            symbolId <- symbol.id.uuidString,
            symbolName <- symbol.name,
            symbolCategory <- symbol.category.rawValue,
            symbolFrequency <- symbol.frequency,
            symbolLastSeen <- symbol.lastSeen,
            // R2 fields
            symbolEmotionalTag <- symbol.emotionalTag,
            symbolRarityScore <- symbol.rarityScore
        )
        try db.run(insert)
    }

    func fetchAllSymbols() throws -> [Symbol] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [Symbol] = []
        for row in try db.prepare(symbols.order(symbolFrequency.desc)) {
            guard let id = UUID(uuidString: row[symbolId]),
                  let category = SymbolCategory(rawValue: row[symbolCategory]) else { continue }

            let symbol = Symbol(
                id: id,
                name: row[symbolName],
                category: category,
                frequency: row[symbolFrequency],
                lastSeen: row[symbolLastSeen],
                emotionalTag: row[symbolEmotionalTag],
                rarityScore: row[symbolRarityScore]
            )
            result.append(symbol)
        }
        return result
    }

    func fetchSymbolsForDream(id: UUID) throws -> [Symbol] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = dreamSymbols.filter(junctionDreamId == id.uuidString)
        var result: [Symbol] = []

        for row in try db.prepare(query) {
            guard let symbolUUID = UUID(uuidString: row[junctionSymbolId]),
                  let symbolRow = try db.pluck(symbols.filter(symbolId == symbolUUID.uuidString)),
                  let category = SymbolCategory(rawValue: symbolRow[symbolCategory]) else { continue }

            let symbol = Symbol(
                id: symbolUUID,
                name: symbolRow[symbolName],
                category: category,
                frequency: symbolRow[symbolFrequency],
                lastSeen: symbolRow[symbolLastSeen],
                emotionalTag: row[junctionEmotionalTag] ?? symbolRow[symbolEmotionalTag],
                rarityScore: symbolRow[symbolRarityScore]
            )
            result.append(symbol)
        }
        return result
    }

    func fetchDreamsForSymbol(symbolId: UUID) throws -> [Dream] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = dreamSymbols.filter(junctionSymbolId == symbolId.uuidString)
        var result: [Dream] = []

        for row in try db.prepare(query) {
            guard let dreamUUID = UUID(uuidString: row[junctionDreamId]),
                  let dream = try fetchDream(id: dreamUUID) else { continue }
            result.append(dream)
        }
        return result
    }

    private func linkDreamSymbol(dreamId: UUID, symbolId: UUID, emotionalTag: String?) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let insert = dreamSymbols.insert(or: .ignore,
            junctionDreamId <- dreamId.uuidString,
            junctionSymbolId <- symbolId.uuidString,
            junctionEmotionalTag <- emotionalTag
        )
        try db.run(insert)
    }

    func incrementSymbolFrequency(symbolId: UUID) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let symbol = symbols.filter(self.symbolId == symbolId.uuidString)
        try db.run(symbol.update(symbolFrequency++))
    }
}

enum DatabaseError: Error {
    case connectionFailed
    case queryFailed
}
