import Foundation
import SwiftUI

// MARK: - Anonymous Dream (shared to public pool)

struct AnonymousDream: Identifiable, Codable, Equatable {
    let id: UUID
    let dreamId: UUID
    let sharedAt: Date
    let mood: Dream.Mood
    let lucidityLevel: Int
    let detectedSymbols: [String]
    let summary: String
    let narrativeSnippet: String
    let communityTag: String
    var likes: Int
    var commentCount: Int

    init(
        id: UUID = UUID(),
        dreamId: UUID,
        sharedAt: Date = Date(),
        mood: Dream.Mood,
        lucidityLevel: Int,
        detectedSymbols: [String],
        summary: String,
        narrativeSnippet: String,
        communityTag: String = "general",
        likes: Int = 0,
        commentCount: Int = 0
    ) {
        self.id = id
        self.dreamId = dreamId
        self.sharedAt = sharedAt
        self.mood = mood
        self.lucidityLevel = lucidityLevel
        self.detectedSymbols = detectedSymbols
        self.summary = summary
        self.narrativeSnippet = narrativeSnippet
        self.communityTag = communityTag
        self.likes = likes
        self.commentCount = commentCount
    }
}

// MARK: - Shared Dream (user's dream shared somewhere)

struct SharedDream: Identifiable, Codable, Equatable {
    let id: UUID
    let dreamId: UUID
    let sharedAt: Date
    let sharedTo: ShareDestination
    let isAnonymous: Bool
    let communityTag: String?

    init(
        id: UUID = UUID(),
        dreamId: UUID,
        sharedAt: Date = Date(),
        sharedTo: ShareDestination,
        isAnonymous: Bool = true,
        communityTag: String? = nil
    ) {
        self.id = id
        self.dreamId = dreamId
        self.sharedAt = sharedAt
        self.sharedTo = sharedTo
        self.isAnonymous = isAnonymous
        self.communityTag = communityTag
    }
}

enum ShareDestination: String, Codable, CaseIterable {
    case anonymousPool = "Anonymous Pool"
    case dreamInterpreters = "Dream Interpreters"
    case lucidDreamers = "Lucid Dreamers"
    case symbolCollectors = "Symbol Collectors"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .anonymousPool: return "person.fill.questionmark"
        case .dreamInterpreters: return "brain.head.profile"
        case .lucidDreamers: return "sparkles"
        case .symbolCollectors: return "star.circle"
        case .custom: return "folder"
        }
    }

    var description: String {
        switch self {
        case .anonymousPool: return "Share with the global dream community anonymously"
        case .dreamInterpreters: return "Share dreams for interpretation and analysis"
        case .lucidDreamers: return "Connect with experienced lucid dreamers"
        case .symbolCollectors: return "Share dreams to build collective symbol database"
        case .custom: return "Share to a custom group"
        }
    }
}

// MARK: - Dream Comment

struct DreamComment: Identifiable, Codable, Equatable {
    let id: UUID
    let dreamId: UUID
    let authorName: String
    let content: String
    let createdAt: Date
    var likes: Int

    init(
        id: UUID = UUID(),
        dreamId: UUID,
        authorName: String = "Anonymous Dreamer",
        content: String,
        createdAt: Date = Date(),
        likes: Int = 0
    ) {
        self.id = id
        self.dreamId = dreamId
        self.authorName = authorName
        self.content = content
        self.createdAt = createdAt
        self.likes = likes
    }
}

// MARK: - Sleep Correlation

struct SleepCorrelation: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sleepQuality: SleepQuality
    let sleepDuration: TimeInterval
    let deepSleepPercent: Double
    let remPercent: Double
    let screenTimeBeforeBed: TimeInterval?
    let dreamSymbols: [String]
    let hadNightmare: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        sleepQuality: SleepQuality,
        sleepDuration: TimeInterval,
        deepSleepPercent: Double = 0.0,
        remPercent: Double = 0.0,
        screenTimeBeforeBed: TimeInterval? = nil,
        dreamSymbols: [String] = [],
        hadNightmare: Bool = false
    ) {
        self.id = id
        self.date = date
        self.sleepQuality = sleepQuality
        self.sleepDuration = sleepDuration
        self.deepSleepPercent = deepSleepPercent
        self.remPercent = remPercent
        self.screenTimeBeforeBed = screenTimeBeforeBed
        self.dreamSymbols = dreamSymbols
        self.hadNightmare = hadNightmare
    }

    enum SleepQuality: String, Codable, CaseIterable {
        case poor = "Poor"
        case fair = "Fair"
        case good = "Good"
        case excellent = "Excellent"

        var color: String {
            switch self {
            case .poor: return "F87171"
            case .fair: return "FBBF24"
            case .good: return "34D399"
            case .excellent: return "5EEAD4"
            }
        }
    }
}

// MARK: - Sleep Insight

struct SleepInsight: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let insightType: InsightType
    let relevantSymbols: [String]
    let confidence: Double

    enum InsightType {
        case correlation
        case pattern
        case tip

        var icon: String {
            switch self {
            case .correlation: return "arrow.left.arrow.right"
            case .pattern: return "waveform.path.ecg"
            case .tip: return "lightbulb"
            }
        }

        var color: String {
            switch self {
            case .correlation: return "5EEAD4"
            case .pattern: return "C084FC"
            case .tip: return "FCD34D"
            }
        }
    }
}

// MARK: - Dream Sharing Service

@MainActor
final class DreamSharingService: ObservableObject {
    static let shared = DreamSharingService()

    private let sharedDreamsKey = "shared_dreams"
    private let anonymousPoolKey = "anonymous_pool"
    private let commentsKey = "dream_comments"

    private init() {
        generateSampleDataIfNeeded()
    }

    // MARK: - Dream Sharing

    func shareDream(_ dream: Dream, anonymously: Bool, to destination: ShareDestination = .anonymousPool, communityTag: String? = nil) -> SharedDream {
        var sharedDream = SharedDream(
            dreamId: dream.id,
            sharedAt: Date(),
            sharedTo: destination,
            isAnonymous: anonymously,
            communityTag: communityTag
        )

        var shared = loadSharedDreams()
        shared.append(sharedDream)
        saveSharedDreams(shared)

        if anonymously {
            let anonymous = AnonymousDream(
                dreamId: dream.id,
                mood: dream.mood,
                lucidityLevel: dream.lucidityLevel,
                detectedSymbols: dream.detectedSymbols,
                summary: dream.summary ?? "Shared dream",
                narrativeSnippet: String(dream.narrative.prefix(200)),
                communityTag: communityTag ?? "general"
            )
            var pool = loadAnonymousPool()
            pool.append(anonymous)
            saveAnonymousPool(pool)
        }

        return sharedDream
    }

    func getSharedDreams() -> [SharedDream] {
        loadSharedDreams().sorted { $0.sharedAt > $1.sharedAt }
    }

    func getAnonymousPool(tag: String? = nil) -> [AnonymousDream] {
        let pool = loadAnonymousPool().sorted { $0.sharedAt > $1.sharedAt }
        if let tag = tag {
            return pool.filter { $0.communityTag.lowercased() == tag.lowercased() }
        }
        return pool
    }

    func removeSharedDream(_ sharedDream: SharedDream) {
        var shared = loadSharedDreams()
        shared.removeAll { $0.id == sharedDream.id }
        saveSharedDreams(shared)

        if sharedDream.isAnonymous {
            var pool = loadAnonymousPool()
            pool.removeAll { $0.dreamId == sharedDream.dreamId }
            saveAnonymousPool(pool)
        }
    }

    // MARK: - Comments

    func addComment(to dreamId: UUID, content: String) -> DreamComment {
        let comment = DreamComment(dreamId: dreamId, content: content)
        var comments = loadComments()
        comments.append(comment)
        saveComments(comments)
        return comment
    }

    func getComments(for dreamId: UUID) -> [DreamComment] {
        loadComments().filter { $0.dreamId == dreamId }.sorted { $0.createdAt < $1.createdAt }
    }

    func likeComment(_ comment: DreamComment) {
        var comments = loadComments()
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[index].likes += 1
            saveComments(comments)
        }
    }

    // MARK: - Sleep Correlation

    func recordSleepCorrelation(_ correlation: SleepCorrelation) {
        var correlations = loadSleepCorrelations()
        correlations.append(correlation)
        saveSleepCorrelations(correlations)
    }

    func getSleepCorrelations(limit: Int = 30) -> [SleepCorrelation] {
        loadSleepCorrelations()
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }

    func generateSleepInsights() -> [SleepInsight] {
        let correlations = getSleepCorrelations(limit: 30)
        var insights: [SleepInsight] = []

        // Screen time correlation
        let withScreenTime = correlations.filter { $0.screenTimeBeforeBed != nil }
        if withScreenTime.count >= 3 {
            let avgScreenBeforeNightmare = withScreenTime.filter { $0.hadNightmare }.compactMap { $0.screenTimeBeforeBed }.reduce(0, +) / Double(max(1, withScreenTime.filter { $0.hadNightmare }.count))
            let avgScreenNoNightmare = withScreenTime.filter { !$0.hadNightmare }.compactMap { $0.screenTimeBeforeBed }.reduce(0, +) / Double(max(1, withScreenTime.filter { !$0.hadNightmare }.count))

            if avgScreenBeforeNightmare > avgScreenNoNightmare * 1.5 {
                insights.append(SleepInsight(
                    id: UUID(),
                    title: "Screen Time & Nightmares",
                    description: "Your nightmare frequency appears higher on days with extended screen time before bed. Consider a 30-minute device-free wind-down routine.",
                    insightType: .correlation,
                    relevantSymbols: [],
                    confidence: 0.75
                ))
            }
        }

        // Deep sleep & flying dreams correlation
        let deepSleepAvg = correlations.filter { $0.deepSleepPercent > 0 }.map { $0.deepSleepPercent }.reduce(0, +) / Double(max(1, correlations.filter { $0.deepSleepPercent > 0 }.count))
        let flyingDreams = correlations.filter { $0.dreamSymbols.contains { $0.lowercased().contains("flight") || $0.lowercased().contains("flying") || $0.lowercased().contains("fly") } }

        if !flyingDreams.isEmpty {
            let avgDeepSleepForFlying = flyingDreams.map { $0.deepSleepPercent }.reduce(0, +) / Double(flyingDreams.count)
            if avgDeepSleepForFlying > deepSleepAvg * 1.2 {
                insights.append(SleepInsight(
                    id: UUID(),
                    title: "Deep Sleep & Flying Dreams",
                    description: "Your flying dreams tend to occur after nights with above-average deep sleep. Your brain may be better processing emotions during extended deep sleep cycles.",
                    insightType: .correlation,
                    relevantSymbols: ["flight"],
                    confidence: 0.68
                ))
            }
        }

        // Pattern: lucid dreams and sleep quality
        let lucidDreams = correlations.filter { $0.sleepQuality == .excellent || $0.sleepQuality == .good }
        if lucidDreams.count >= 5 {
            insights.append(SleepInsight(
                id: UUID(),
                title: "Sleep Quality Supports Lucidity",
                description: "Your lucid dreams occur predominantly on nights with good or excellent sleep quality. Prioritizing sleep hygiene may enhance your lucidity practice.",
                insightType: .pattern,
                relevantSymbols: [],
                confidence: 0.82
            ))
        }

        // Tip
        insights.append(SleepInsight(
            id: UUID(),
            title: "Dream Journal Consistency",
            description: "Recording dreams within 5 minutes of waking preserves 65% more detail. Keep your journal by your bed and try voice recording for quick capture.",
            insightType: .tip,
            relevantSymbols: [],
            confidence: 1.0
        ))

        return insights
    }

    func correlateDreamWithSleep(_ dream: Dream) -> SleepCorrelation? {
        let correlations = getSleepCorrelations(limit: 7)
        return correlations.first { Calendar.current.isDate($0.date, inSameDayAs: dream.date) }
    }

    // MARK: - Persistence

    private func loadSharedDreams() -> [SharedDream] {
        guard let data = UserDefaults.standard.data(forKey: sharedDreamsKey),
              let decoded = try? JSONDecoder().decode([SharedDream].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveSharedDreams(_ dreams: [SharedDream]) {
        if let encoded = try? JSONEncoder().encode(dreams) {
            UserDefaults.standard.set(encoded, forKey: sharedDreamsKey)
        }
    }

    private func loadAnonymousPool() -> [AnonymousDream] {
        guard let data = UserDefaults.standard.data(forKey: anonymousPoolKey),
              let decoded = try? JSONDecoder().decode([AnonymousDream].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveAnonymousPool(_ pool: [AnonymousDream]) {
        if let encoded = try? JSONEncoder().encode(pool) {
            UserDefaults.standard.set(encoded, forKey: anonymousPoolKey)
        }
    }

    private func loadComments() -> [DreamComment] {
        guard let data = UserDefaults.standard.data(forKey: commentsKey),
              let decoded = try? JSONDecoder().decode([DreamComment].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveComments(_ comments: [DreamComment]) {
        if let encoded = try? JSONEncoder().encode(comments) {
            UserDefaults.standard.set(encoded, forKey: commentsKey)
        }
    }

    private func loadSleepCorrelations() -> [SleepCorrelation] {
        guard let data = UserDefaults.standard.data(forKey: "sleep_correlations"),
              let decoded = try? JSONDecoder().decode([SleepCorrelation].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveSleepCorrelations(_ correlations: [SleepCorrelation]) {
        if let encoded = try? JSONEncoder().encode(correlations) {
            UserDefaults.standard.set(encoded, forKey: "sleep_correlations")
        }
    }

    // MARK: - Sample Data

    private func generateSampleDataIfNeeded() {
        guard loadAnonymousPool().isEmpty else { return }

        let samplePool: [AnonymousDream] = [
            AnonymousDream(
                dreamId: UUID(),
                mood: .peaceful,
                lucidityLevel: 4,
                detectedSymbols: ["ocean", "stars", "flight"],
                summary: "Soaring above a luminescent sea under northern lights",
                narrativeSnippet: "I found myself flying over an ocean that glowed with bioluminescent light...",
                communityTag: "lucid-dreamers",
                likes: 24,
                commentCount: 3
            ),
            AnonymousDream(
                dreamId: UUID(),
                mood: .mysterious,
                lucidityLevel: 2,
                detectedSymbols: ["library", "books", "doors"],
                summary: "An endless library where each book contained a different memory",
                narrativeSnippet: "The shelves stretched infinitely in every direction, each book pulsing with soft light...",
                communityTag: "dream-interpreters",
                likes: 18,
                commentCount: 5
            ),
            AnonymousDream(
                dreamId: UUID(),
                mood: .adventurous,
                lucidityLevel: 5,
                detectedSymbols: ["mountain", "bird", "wind"],
                summary: "Transforming into a bird to scale impossible peaks",
                narrativeSnippet: "My arms became wings and I soared upward toward snow-capped mountains...",
                communityTag: "lucid-dreamers",
                likes: 31,
                commentCount: 2
            ),
            AnonymousDream(
                dreamId: UUID(),
                mood: .anxious,
                lucidityLevel: 1,
                detectedSymbols: ["city", "crowd", "lost"],
                summary: "Searching through an endless maze of city streets",
                narrativeSnippet: "Every corner I turned revealed more streets stretching into fog...",
                communityTag: "dream-interpreters",
                likes: 12,
                commentCount: 7
            ),
            AnonymousDream(
                dreamId: UUID(),
                mood: .joyful,
                lucidityLevel: 3,
                detectedSymbols: ["forest", "animals", "light"],
                summary: "Dancing with luminous forest creatures at twilight",
                narrativeSnippet: "The trees sang as I moved among deer with antlers of starlight...",
                communityTag: "general",
                likes: 42,
                commentCount: 4
            )
        ]

        saveAnonymousPool(samplePool)

        // Sample sleep correlations
        let sampleCorrelations: [SleepCorrelation] = [
            SleepCorrelation(
                date: Date(),
                sleepQuality: .excellent,
                sleepDuration: 8.5 * 3600,
                deepSleepPercent: 22,
                remPercent: 28,
                screenTimeBeforeBed: 15 * 60,
                dreamSymbols: ["ocean", "flight", "stars"]
            ),
            SleepCorrelation(
                date: Date().addingTimeInterval(-86400),
                sleepQuality: .good,
                sleepDuration: 7.5 * 3600,
                deepSleepPercent: 18,
                remPercent: 24,
                screenTimeBeforeBed: 45 * 60,
                dreamSymbols: ["library", "books"]
            ),
            SleepCorrelation(
                date: Date().addingTimeInterval(-172800),
                sleepQuality: .fair,
                sleepDuration: 6.5 * 3600,
                deepSleepPercent: 14,
                remPercent: 20,
                screenTimeBeforeBed: 90 * 60,
                dreamSymbols: ["city", "crowd"],
                hadNightmare: true
            )
        ]

        saveSleepCorrelations(sampleCorrelations)
    }
}
