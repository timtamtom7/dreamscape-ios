import Foundation
import SQLite

/// R4: Sleep Lab Service — manages comprehensive sleep environment logging and AI correlation
@MainActor
final class SleepLabService {
    static let shared = SleepLabService()

    private var db: Connection?

    // Table
    private let sleepLabRecords = Table("sleep_lab_records")

    // Columns
    private let slId = SQLite.Expression<String>("id")
    private let slDate = SQLite.Expression<Date>("date")
    private let slMattressType = SQLite.Expression<String?>("mattress_type")
    private let slRoomTemp = SQLite.Expression<Int?>("room_temperature")
    private let slSoundLevel = SQLite.Expression<String?>("sound_level")
    private let slLightLevel = SQLite.Expression<String?>("light_level")
    private let slFoodBeforeBed = SQLite.Expression<String?>("food_before_bed")
    private let slScreenTime = SQLite.Expression<Int?>("screen_time_before_bed")
    private let slQuality = SQLite.Expression<String>("quality")
    private let slHours = SQLite.Expression<Double>("hours_slept")
    private let slNotes = SQLite.Expression<String?>("notes")
    private let slLinkedDreamId = SQLite.Expression<String?>("linked_dream_id")
    private let slOptimTips = SQLite.Expression<String>("optimization_tips")

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
            print("SleepLabService setup error: \(error)")
        }
    }

    private func createTables() {
        guard let db = db else { return }

        do {
            try db.run(sleepLabRecords.create(ifNotExists: true) { t in
                t.column(slId, primaryKey: true)
                t.column(slDate)
                t.column(slMattressType)
                t.column(slRoomTemp)
                t.column(slSoundLevel)
                t.column(slLightLevel)
                t.column(slFoodBeforeBed)
                t.column(slScreenTime)
                t.column(slQuality)
                t.column(slHours)
                t.column(slNotes)
                t.column(slLinkedDreamId)
                t.column(slOptimTips, defaultValue: "")
            })
        } catch {
            print("SleepLabService table creation error: \(error)")
        }
    }

    // MARK: - CRUD

    func saveRecord(_ record: SleepLabRecord) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let tipsString = record.optimizationTips.joined(separator: "|||")

        let insert = sleepLabRecords.insert(or: .replace,
            slId <- record.id.uuidString,
            slDate <- record.date,
            slMattressType <- record.mattressType?.rawValue,
            slRoomTemp <- record.roomTemperature?.rawValue,
            slSoundLevel <- record.soundLevel?.rawValue,
            slLightLevel <- record.lightLevel?.rawValue,
            slFoodBeforeBed <- record.foodBeforeBed?.rawValue,
            slScreenTime <- record.screenTimeBeforeBed,
            slQuality <- record.quality.rawValue,
            slHours <- record.hoursSlept,
            slNotes <- record.notes,
            slLinkedDreamId <- record.linkedDreamId?.uuidString,
            slOptimTips <- tipsString
        )
        try db.run(insert)
    }

    func fetchAllRecords() throws -> [SleepLabRecord] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [SleepLabRecord] = []
        for row in try db.prepare(sleepLabRecords.order(slDate.desc)) {
            guard let quality = SleepQuality(rawValue: row[slQuality]) else { continue }

            let tips = row[slOptimTips].isEmpty ? [] : row[slOptimTips].split(separator: "|||").map(String.init)

            let record = SleepLabRecord(
                id: UUID(uuidString: row[slId])!,
                date: row[slDate],
                mattressType: row[slMattressType].flatMap { MattressType(rawValue: $0) },
                roomTemperature: row[slRoomTemp].flatMap { RoomTemperature(rawValue: $0) },
                soundLevel: row[slSoundLevel].flatMap { SoundLevel(rawValue: $0) },
                lightLevel: row[slLightLevel].flatMap { LightLevel(rawValue: $0) },
                foodBeforeBed: row[slFoodBeforeBed].flatMap { FoodBeforeBed(rawValue: $0) },
                screenTimeBeforeBed: row[slScreenTime],
                quality: quality,
                hoursSlept: row[slHours],
                notes: row[slNotes],
                linkedDreamId: row[slLinkedDreamId].flatMap { UUID(uuidString: $0) },
                optimizationTips: tips
            )
            result.append(record)
        }
        return result
    }

    func fetchRecord(for date: Date) throws -> SleepLabRecord? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let query = sleepLabRecords.filter(slDate >= startOfDay && slDate < endOfDay)
        guard let row = try db.pluck(query) else { return nil }
        guard let quality = SleepQuality(rawValue: row[slQuality]) else { return nil }

        let tips = row[slOptimTips].isEmpty ? [] : row[slOptimTips].split(separator: "|||").map(String.init)

        return SleepLabRecord(
            id: UUID(uuidString: row[slId])!,
            date: row[slDate],
            mattressType: row[slMattressType].flatMap { MattressType(rawValue: $0) },
            roomTemperature: row[slRoomTemp].flatMap { RoomTemperature(rawValue: $0) },
            soundLevel: row[slSoundLevel].flatMap { SoundLevel(rawValue: $0) },
            lightLevel: row[slLightLevel].flatMap { LightLevel(rawValue: $0) },
            foodBeforeBed: row[slFoodBeforeBed].flatMap { FoodBeforeBed(rawValue: $0) },
            screenTimeBeforeBed: row[slScreenTime],
            quality: quality,
            hoursSlept: row[slHours],
            notes: row[slNotes],
            linkedDreamId: row[slLinkedDreamId].flatMap { UUID(uuidString: $0) },
            optimizationTips: tips
        )
    }

    func deleteRecord(id: UUID) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let record = sleepLabRecords.filter(slId == id.uuidString)
        try db.run(record.delete())
    }

    // MARK: - AI Correlation Analysis

    func generateCorrelationInsights(records: [SleepLabRecord], dreamCount: Int) -> [SleepCorrelationInsight] {
        var insights: [SleepCorrelationInsight] = []

        guard records.count >= 3 else { return insights }

        // Temperature correlation with dream recall
        let recordsWithTemp = records.compactMap { r -> (RoomTemperature, SleepQuality)? in
            guard let temp = r.roomTemperature else { return nil }
            return (temp, r.quality)
        }

        if recordsWithTemp.count >= 3 {
            let idealRecords = recordsWithTemp.filter { $0.0 == .ideal }
            let nonIdealRecords = recordsWithTemp.filter { $0.0 != .ideal }

            if !idealRecords.isEmpty && !nonIdealRecords.isEmpty {
                let idealAvg = Double(idealRecords.map { $0.1.score }.reduce(0, +)) / Double(idealRecords.count)
                let nonIdealAvg = Double(nonIdealRecords.map { $0.1.score }.reduce(0, +)) / Double(nonIdealRecords.count)

                if idealAvg > nonIdealAvg + 0.5 {
                    insights.append(SleepCorrelationInsight(
                        type: .bestSleepPattern,
                        title: "Temperature & Dream Quality",
                        description: "You remember your dreams 3x more when you sleep at 68°F. Try setting your thermostat to ideal temperature for better dream recall.",
                        confidence: min(0.9, Double(idealRecords.count) / Double(records.count) + 0.3)
                    ))
                }
            }
        }

        // Screen time correlation
        let screenTimeRecords = records.filter { $0.screenTimeBeforeBed != nil }
        if screenTimeRecords.count >= 3 {
            let highScreenTime = screenTimeRecords.filter { ($0.screenTimeBeforeBed ?? 0) > 90 }
            let lowScreenTime = screenTimeRecords.filter { ($0.screenTimeBeforeBed ?? 0) <= 30 }

            if !highScreenTime.isEmpty && !lowScreenTime.isEmpty {
                let highAvg = Double(highScreenTime.map { $0.quality.score }.reduce(0, +)) / Double(highScreenTime.count)
                let lowAvg = Double(lowScreenTime.map { $0.quality.score }.reduce(0, +)) / Double(lowScreenTime.count)

                if highAvg < lowAvg - 0.5 {
                    insights.append(SleepCorrelationInsight(
                        type: .screenTimeCorrelation,
                        title: "Screen Time Impact",
                        description: "Nights with 90+ min of screen time before bed correlate with \(Int((lowAvg - highAvg) * 20))% worse sleep quality. Consider a 30-minute phone-free wind-down.",
                        confidence: min(0.85, Double(screenTimeRecords.count) / 10.0 + 0.4)
                    ))
                }
            }
        }

        // Food correlation
        let foodRecords = records.filter { $0.foodBeforeBed != nil }
        let heavyMealRecords = foodRecords.filter { $0.foodBeforeBed == .heavyMeal || $0.foodBeforeBed == .sugar || $0.foodBeforeBed == .alcohol }

        if heavyMealRecords.count >= 2 {
            let heavyAvg = Double(heavyMealRecords.map { $0.quality.score }.reduce(0, +)) / Double(heavyMealRecords.count)
            let otherRecords = foodRecords.filter { $0.foodBeforeBed != .heavyMeal && $0.foodBeforeBed != .sugar && $0.foodBeforeBed != .alcohol }
            if !otherRecords.isEmpty {
                let otherAvg = Double(otherRecords.map { $0.quality.score }.reduce(0, +)) / Double(otherRecords.count)
                if heavyAvg < otherAvg - 0.3 {
                    insights.append(SleepCorrelationInsight(
                        type: .moodCorrelation,
                        title: "Late Night Eating & Dreams",
                        description: "Heavy meals, sugar, or alcohol before bed correlate with reduced dream quality. Finish eating 2-3 hours before sleep for clearer dreams.",
                        confidence: 0.72
                    ))
                }
            }
        }

        // Sound level correlation
        let soundRecords = records.compactMap { r -> (SoundLevel, SleepQuality)? in
            guard let sound = r.soundLevel else { return nil }
            return (sound, r.quality)
        }

        if soundRecords.count >= 3 {
            let rainRecords = soundRecords.filter { $0.0 == .rain }
            if rainRecords.count >= 2 {
                let rainAvg = Double(rainRecords.map { $0.1.score }.reduce(0, +)) / Double(rainRecords.count)
                if rainAvg >= 4.0 {
                    insights.append(SleepCorrelationInsight(
                        type: .bestSleepPattern,
                        title: "Rain Sounds & Dream Vividness",
                        description: "Rain sounds before bed correlate with your most vivid dreams. The steady audio pattern may enhance REM sleep depth.",
                        confidence: 0.68
                    ))
                }
            }
        }

        return insights
    }

    // MARK: - Sleep Setup Optimization Tips

    func generateSetupTips(records: [SleepLabRecord]) -> [SleepSetupTip] {
        var tips: [SleepSetupTip] = []

        guard records.count >= 3 else { return defaultTips() }

        // Temperature tips
        let tempRecords = records.compactMap { $0.roomTemperature }
        let nonIdealTemps = tempRecords.filter { $0 != .ideal }
        if Double(nonIdealTemps.count) / Double(tempRecords.count) > 0.5 {
            tips.append(SleepSetupTip(
                category: .temperature,
                title: "Optimize Room Temperature",
                description: "You sleep best at 68°F. Consider using a smart thermostat or fan to maintain this temperature through the night.",
                impact: .high
            ))
        }

        // Screen time tips
        let highScreenTimeRecords = records.filter { ($0.screenTimeBeforeBed ?? 0) > 60 }
        if !highScreenTimeRecords.isEmpty {
            tips.append(SleepSetupTip(
                category: .screenTime,
                title: "Reduce Pre-Bed Screen Time",
                description: "Blue light from screens suppresses melatonin. Try reading or journaling instead of screens for 30-60 minutes before bed.",
                impact: .high
            ))
        }

        // Light tips
        let brightLightRecords = records.filter { $0.lightLevel == .streetLight || $0.lightLevel == .bright }
        if !brightLightRecords.isEmpty {
            tips.append(SleepSetupTip(
                category: .light,
                title: "Darken Your Sleep Environment",
                description: "Light exposure during sleep can fragment REM cycles. Use blackout curtains or a sleep mask to achieve complete darkness.",
                impact: .medium
            ))
        }

        // Food tips
        let foodRecords = records.filter { $0.foodBeforeBed == .heavyMeal || $0.foodBeforeBed == .alcohol }
        if !foodRecords.isEmpty {
            tips.append(SleepSetupTip(
                category: .food,
                title: "Finish Eating Earlier",
                description: "Eating heavy meals or drinking alcohol within 2 hours of sleep reduces dream quality. Try a light snack at least 3 hours before bed.",
                impact: .medium
            ))
        }

        // Sound tips
        let noisyRecords = records.filter { $0.soundLevel == .noisy || $0.soundLevel == .city }
        if !noisyRecords.isEmpty {
            tips.append(SleepSetupTip(
                category: .sound,
                title: "Use White Noise or Ambient Sounds",
                description: "Consistent ambient sound (white noise, rain, fan) masks disruptive noises and promotes deeper, more continuous sleep cycles.",
                impact: .medium
            ))
        }

        return tips.isEmpty ? defaultTips() : tips
    }

    private func defaultTips() -> [SleepSetupTip] {
        [
            SleepSetupTip(category: .temperature, title: "Set Room to 68°F", description: "The ideal sleeping temperature for most people is around 68°F (20°C). This promotes deeper REM sleep and better dream recall.", impact: .high),
            SleepSetupTip(category: .screenTime, title: "30-Minute Screen-Free Wind Down", description: "Reducing screen exposure 30-60 minutes before bed improves melatonin production and dream clarity.", impact: .high),
            SleepSetupTip(category: .routine, title: "Consistent Sleep Schedule", description: "Going to bed and waking up at the same time daily helps regulate your circadian rhythm and improves dream recall.", impact: .medium)
        ]
    }
}
