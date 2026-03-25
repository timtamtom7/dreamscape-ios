import Foundation

/// R3: Sleep quality data — tracks how well the user slept alongside their dreams
struct SleepData: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var quality: SleepQuality
    var hoursSlept: Double
    var notes: String?

    // R3: Correlation insights
    var linkedDreamId: UUID?
    var screenTimeBeforeBed: Int? // minutes

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        quality: SleepQuality,
        hoursSlept: Double,
        notes: String? = nil,
        linkedDreamId: UUID? = nil,
        screenTimeBeforeBed: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.quality = quality
        self.hoursSlept = hoursSlept
        self.notes = notes
        self.linkedDreamId = linkedDreamId
        self.screenTimeBeforeBed = screenTimeBeforeBed
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum SleepQuality: String, Codable, CaseIterable, Identifiable {
    case terrible = "terrible"
    case poor = "poor"
    case fair = "fair"
    case good = "good"
    case excellent = "excellent"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var emoji: String {
        switch self {
        case .terrible: return "😫"
        case .poor: return "😕"
        case .fair: return "😐"
        case .good: return "😊"
        case .excellent: return "😴"
        }
    }

    var color: String {
        switch self {
        case .terrible: return "F87171"
        case .poor: return "FB923C"
        case .fair: return "FBBF24"
        case .good: return "34D399"
        case .excellent: return "5EEAD4"
        }
    }

    var score: Int {
        switch self {
        case .terrible: return 1
        case .poor: return 2
        case .fair: return 3
        case .good: return 4
        case .excellent: return 5
        }
    }
}

/// R3: Sleep correlation analysis
struct SleepCorrelationInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double // 0.0 to 1.0

    enum InsightType {
        case screenTimeCorrelation
        case moodCorrelation
        case recurringDreamImpact
        case bestSleepPattern
    }
}
