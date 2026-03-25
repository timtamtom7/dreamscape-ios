import Foundation
import SQLite

/// R3: Sleep data persistence and correlation analysis
@MainActor
final class SleepDataService {
    static let shared = SleepDataService()

    private var db: Connection?

    // Table
    private let sleepRecords = Table("sleep_records")

    // Columns
    private let sleepId = SQLite.Expression<String>("id")
    private let sleepDate = SQLite.Expression<Date>("date")
    private let sleepQuality = SQLite.Expression<String>("quality")
    private let sleepHours = SQLite.Expression<Double>("hours_slept")
    private let sleepNotes = SQLite.Expression<String?>("notes")
    private let sleepLinkedDreamId = SQLite.Expression<String?>("linked_dream_id")
    private let sleepScreenTime = SQLite.Expression<Int?>("screen_time_before_bed")

    // Dream-Art table for R3
    private let dreamArts = Table("dream_arts")
    private let artId = SQLite.Expression<String>("id")
    private let artDreamId = SQLite.Expression<String>("dream_id")
    private let artImageURL = SQLite.Expression<String?>("image_url")
    private let artPrompt = SQLite.Expression<String>("prompt")
    private let artEmotionalPalette = SQLite.Expression<String>("emotional_palette")
    private let artDominantColors = SQLite.Expression<String>("dominant_colors")
    private let artStyle = SQLite.Expression<String>("style")
    private let artCreatedAt = SQLite.Expression<Date>("created_at")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("dreamscape.sqlite3")
            db = try Connection(dbPath.path)
            createTables()
        } catch {
            print("SleepDataService setup error: \(error)")
        }
    }

    private func createTables() {
        guard let db = db else { return }

        do {
            try db.run(sleepRecords.create(ifNotExists: true) { t in
                t.column(sleepId, primaryKey: true)
                t.column(sleepDate)
                t.column(sleepQuality)
                t.column(sleepHours)
                t.column(sleepNotes)
                t.column(sleepLinkedDreamId)
                t.column(sleepScreenTime)
            })

            try db.run(dreamArts.create(ifNotExists: true) { t in
                t.column(artId, primaryKey: true)
                t.column(artDreamId)
                t.column(artImageURL)
                t.column(artPrompt)
                t.column(artEmotionalPalette, defaultValue: "")
                t.column(artDominantColors, defaultValue: "")
                t.column(artStyle, defaultValue: DreamArtStyle.abstract.rawValue)
                t.column(artCreatedAt)
            })
        } catch {
            print("SleepDataService table creation error: \(error)")
        }
    }

    // MARK: - Sleep Records

    func saveSleepRecord(_ record: SleepData) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let insert = sleepRecords.insert(or: .replace,
            sleepId <- record.id.uuidString,
            sleepDate <- record.date,
            sleepQuality <- record.quality.rawValue,
            sleepHours <- record.hoursSlept,
            sleepNotes <- record.notes,
            sleepLinkedDreamId <- record.linkedDreamId?.uuidString,
            sleepScreenTime <- record.screenTimeBeforeBed
        )
        try db.run(insert)
    }

    func fetchAllSleepRecords() throws -> [SleepData] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [SleepData] = []
        for row in try db.prepare(sleepRecords.order(sleepDate.desc)) {
            guard let quality = SleepQuality(rawValue: row[sleepQuality]) else { continue }

            let record = SleepData(
                id: UUID(uuidString: row[sleepId])!,
                date: row[sleepDate],
                quality: quality,
                hoursSlept: row[sleepHours],
                notes: row[sleepNotes],
                linkedDreamId: row[sleepLinkedDreamId].flatMap { UUID(uuidString: $0) },
                screenTimeBeforeBed: row[sleepScreenTime]
            )
            result.append(record)
        }
        return result
    }

    func fetchSleepRecord(for date: Date) throws -> SleepData? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let query = sleepRecords.filter(sleepDate >= startOfDay && sleepDate < endOfDay)
        guard let row = try db.pluck(query) else { return nil }
        guard let quality = SleepQuality(rawValue: row[sleepQuality]) else { return nil }

        return SleepData(
            id: UUID(uuidString: row[sleepId])!,
            date: row[sleepDate],
            quality: quality,
            hoursSlept: row[sleepHours],
            notes: row[sleepNotes],
            linkedDreamId: row[sleepLinkedDreamId].flatMap { UUID(uuidString: $0) },
            screenTimeBeforeBed: row[sleepScreenTime]
        )
    }

    func deleteSleepRecord(id: UUID) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let record = sleepRecords.filter(sleepId == id.uuidString)
        try db.run(record.delete())
    }

    // MARK: - Sleep Correlation Analysis

    func generateInsights(dreams: [Dream], sleepRecords: [SleepData]) -> [SleepCorrelationInsight] {
        var insights: [SleepCorrelationInsight] = []

        // Correlate screen time with dream quality
        let screenTimeRecords = sleepRecords.filter { $0.screenTimeBeforeBed != nil }
        if screenTimeRecords.count >= 3 {
            let avgScreenTime = screenTimeRecords.compactMap { $0.screenTimeBeforeBed }.reduce(0, +) / screenTimeRecords.count
            let badSleepWithHighScreen = screenTimeRecords.filter {
                ($0.quality == .terrible || $0.quality == .poor) && ($0.screenTimeBeforeBed ?? 0) > 60
            }

            if Double(badSleepWithHighScreen.count) / Double(screenTimeRecords.count) > 0.4 {
                insights.append(SleepCorrelationInsight(
                    type: .screenTimeCorrelation,
                    title: "Screen Time Impact",
                    description: "Your worst dreams often follow late-night screen time. Reducing screen exposure \(avgScreenTime > 90 ? "60+" : "45+") minutes before bed may improve dream clarity.",
                    confidence: 0.75
                ))
            }
        }

        // Correlate mood with sleep quality
        let moodSleepPairs = dreams.compactMap { dream -> (MoodTag, SleepData)? in
            guard let linkedId = sleepRecords.first(where: { $0.linkedDreamId == dream.id })?.linkedDreamId,
                  let sleep = sleepRecords.first(where: { $0.id.uuidString == linkedId.uuidString }) ?? sleepRecords.first(where: { Calendar.current.isDate($0.date, inSameDayAs: dream.createdAt) }),
                  let mood = dream.mood else { return nil }
            return (mood, sleep)
        }

        let anxiousBadSleep = moodSleepPairs.filter { $0.0 == .anxious && ($0.1.quality == .terrible || $0.1.quality == .poor) }
        if anxiousBadSleep.count >= 2 {
            insights.append(SleepCorrelationInsight(
                type: .moodCorrelation,
                title: "Anxiety & Sleep Quality",
                description: "Anxious dreams tend to correlate with poor sleep quality. Consider relaxation techniques before bed on high-stress days.",
                confidence: 0.68
            ))
        }

        // Best sleep pattern analysis
        let goodSleepRecords = sleepRecords.filter { $0.quality == .good || $0.quality == .excellent }
        if goodSleepRecords.count >= 5 {
            let avgHours = goodSleepRecords.map { $0.hoursSlept }.reduce(0, +) / Double(goodSleepRecords.count)
            insights.append(SleepCorrelationInsight(
                type: .bestSleepPattern,
                title: "Optimal Sleep Duration",
                description: "Your best sleep nights average \(String(format: "%.1f", avgHours)) hours. Maintaining this duration consistently leads to more vivid dreams.",
                confidence: 0.72
            ))
        }

        return insights
    }

    // MARK: - Dream Art (R3)

    func saveDreamArt(_ art: DreamArt) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let emotionalPalette = art.emotionalPalette.joined(separator: ",")
        let colors = art.dominantColors.joined(separator: ",")

        let insert = dreamArts.insert(or: .replace,
            artId <- art.id.uuidString,
            artDreamId <- art.dreamId.uuidString,
            artImageURL <- art.imageURL?.absoluteString,
            artPrompt <- art.prompt,
            artEmotionalPalette <- emotionalPalette,
            artDominantColors <- colors,
            artStyle <- art.style.rawValue,
            artCreatedAt <- art.createdAt
        )
        try db.run(insert)
    }

    func fetchDreamArt(for dreamId: UUID) throws -> DreamArt? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = dreamArts.filter(artDreamId == dreamId.uuidString)
        guard let row = try db.pluck(query) else { return nil }

        let emotionalPalette = row[artEmotionalPalette].split(separator: ",").map(String.init)
        let colors = row[artDominantColors].split(separator: ",").map(String.init)

        return DreamArt(
            id: UUID(uuidString: row[artId])!,
            dreamId: UUID(uuidString: row[artDreamId])!,
            imageURL: row[artImageURL].flatMap { URL(string: $0) },
            prompt: row[artPrompt],
            emotionalPalette: emotionalPalette,
            dominantColors: colors,
            style: DreamArtStyle(rawValue: row[artStyle]) ?? .abstract,
            createdAt: row[artCreatedAt]
        )
    }

    func fetchAllDreamArts() throws -> [DreamArt] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [DreamArt] = []
        for row in try db.prepare(dreamArts.order(artCreatedAt.desc)) {
            let emotionalPalette = row[artEmotionalPalette].split(separator: ",").map(String.init)
            let colors = row[artDominantColors].split(separator: ",").map(String.init)

            let art = DreamArt(
                id: UUID(uuidString: row[artId])!,
                dreamId: UUID(uuidString: row[artDreamId])!,
                imageURL: row[artImageURL].flatMap { URL(string: $0) },
                prompt: row[artPrompt],
                emotionalPalette: emotionalPalette,
                dominantColors: colors,
                style: DreamArtStyle(rawValue: row[artStyle]) ?? .abstract,
                createdAt: row[artCreatedAt]
            )
            result.append(art)
        }
        return result
    }
}
