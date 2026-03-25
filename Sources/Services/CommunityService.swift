import Foundation

/// R4: Community Service — anonymous social features for dream symbol sharing
/// Uses local mock data to simulate aggregate community patterns
@MainActor
final class CommunityService {
    static let shared = CommunityService()

    private init() {}

    // MARK: - Anonymous Symbol Submission

    struct AnonymousSymbolSubmission: Identifiable, Codable {
        let id: UUID
        let symbolName: String
        let category: SymbolCategory
        let dreamContext: String  // e.g., "recurring", "recent", "vivid"
        let submittedAt: Date

        // Aggregate data (calculated from community)
        var communityPercentage: Int  // % of dreamers with similar symbols
        var topInterpretation: String
        var relatedEmotions: [String]
    }

    // MARK: - Community Aggregate Patterns

    struct CommunityPattern: Identifiable {
        let id = UUID()
        let symbolName: String
        let category: SymbolCategory
        let percentageOfDreamers: Int
        let topMeaning: String
        let interpretations: [Interpretation]
    }

    struct Interpretation: Identifiable {
        let id = UUID()
        let meaning: String
        let frequency: Int  // how common this interpretation is in community
        let emotionalTag: String
    }

    // MARK: - Mock Community Data

    private let mockPatterns: [CommunityPattern] = [
        CommunityPattern(
            symbolName: "Water",
            category: .place,
            percentageOfDreamers: 72,
            topMeaning: "Processing anxiety or emotional depth",
            interpretations: [
                Interpretation(meaning: "Emotional processing", frequency: 45, emotionalTag: "Anxiety"),
                Interpretation(meaning: "Life transitions", frequency: 25, emotionalTag: "Change"),
                Interpretation(meaning: "Cleansing and renewal", frequency: 20, emotionalTag: "Peace"),
                Interpretation(meaning: "Unconscious depths", frequency: 10, emotionalTag: "Mystery")
            ]
        ),
        CommunityPattern(
            symbolName: "Flying",
            category: .emotion,
            percentageOfDreamers: 68,
            topMeaning: "Desire for freedom or escape",
            interpretations: [
                Interpretation(meaning: "Freedom and ambition", frequency: 50, emotionalTag: "Joy"),
                Interpretation(meaning: "Escaping a situation", frequency: 25, emotionalTag: "Anxiety"),
                Interpretation(meaning: "Control and power", frequency: 15, emotionalTag: "Empowerment"),
                Interpretation(meaning: "Spiritual transcendence", frequency: 10, emotionalTag: "Awe")
            ]
        ),
        CommunityPattern(
            symbolName: "Being Chased",
            category: .emotion,
            percentageOfDreamers: 65,
            topMeaning: "Avoiding something in waking life",
            interpretations: [
                Interpretation(meaning: "Avoiding a problem", frequency: 40, emotionalTag: "Fear"),
                Interpretation(meaning: "Health concerns", frequency: 25, emotionalTag: "Anxiety"),
                Interpretation(meaning: "Past trauma surfacing", frequency: 20, emotionalTag: "Dark"),
                Interpretation(meaning: "Responsibility overwhelm", frequency: 15, emotionalTag: "Stress")
            ]
        ),
        CommunityPattern(
            symbolName: "Falling",
            category: .emotion,
            percentageOfDreamers: 61,
            topMeaning: "Loss of control or insecurity",
            interpretations: [
                Interpretation(meaning: "Insecurity in waking life", frequency: 45, emotionalTag: "Anxiety"),
                Interpretation(meaning: "Letting go of something", frequency: 25, emotionalTag: "Release"),
                Interpretation(meaning: "Fear of failure", frequency: 20, emotionalTag: "Fear"),
                Interpretation(meaning: "Need for grounding", frequency: 10, emotionalTag: "Peace")
            ]
        ),
        CommunityPattern(
            symbolName: "Teeth Falling Out",
            category: .object,
            percentageOfDreamers: 45,
            topMeaning: "Self-image concerns or major change",
            interpretations: [
                Interpretation(meaning: "Self-image/anxiety", frequency: 40, emotionalTag: "Anxiety"),
                Interpretation(meaning: "Major life transition", frequency: 30, emotionalTag: "Change"),
                Interpretation(meaning: "Communication concerns", frequency: 20, emotionalTag: "Confusion"),
                Interpretation(meaning: "Aging fears", frequency: 10, emotionalTag: "Melancholy")
            ]
        ),
        CommunityPattern(
            symbolName: "Animals",
            category: .object,
            percentageOfDreamers: 58,
            topMeaning: "Connecting with instincts or nature",
            interpretations: [
                Interpretation(meaning: "Animal instincts", frequency: 35, emotionalTag: "Mystery"),
                Interpretation(meaning: "Relationship with nature", frequency: 25, emotionalTag: "Peace"),
                Interpretation(meaning: "Untamed aspects of self", frequency: 25, emotionalTag: "Empowerment"),
                Interpretation(meaning: "Loyalty and companionship", frequency: 15, emotionalTag: "Joy")
            ]
        ),
        CommunityPattern(
            symbolName: "House",
            category: .place,
            percentageOfDreamers: 55,
            topMeaning: "Self-image and mental state",
            interpretations: [
                Interpretation(meaning: "Your mind/self", frequency: 40, emotionalTag: "Mystery"),
                Interpretation(meaning: "Memories and past", frequency: 25, emotionalTag: "Nostalgia"),
                Interpretation(meaning: "Future aspirations", frequency: 20, emotionalTag: "Hope"),
                Interpretation(meaning: "Family and relationships", frequency: 15, emotionalTag: "Confusion")
            ]
        ),
        CommunityPattern(
            symbolName: "Car",
            category: .object,
            percentageOfDreamers: 42,
            topMeaning: "Life direction and control",
            interpretations: [
                Interpretation(meaning: "Life direction", frequency: 40, emotionalTag: "Confusion"),
                Interpretation(meaning: "Personal control", frequency: 30, emotionalTag: "Empowerment"),
                Interpretation(meaning: "Journey and progress", frequency: 20, emotionalTag: "Hope"),
                Interpretation(meaning: "Speed of life changes", frequency: 10, emotionalTag: "Anxiety")
            ]
        ),
        CommunityPattern(
            symbolName: "Death",
            category: .emotion,
            percentageOfDreamers: 38,
            topMeaning: "Transformation and endings",
            interpretations: [
                Interpretation(meaning: "Endings and new beginnings", frequency: 50, emotionalTag: "Change"),
                Interpretation(meaning: "Fear of loss", frequency: 25, emotionalTag: "Fear"),
                Interpretation(meaning: "Letting go of the past", frequency: 15, emotionalTag: "Release"),
                Interpretation(meaning: "Life transition anxiety", frequency: 10, emotionalTag: "Anxiety")
            ]
        ),
        CommunityPattern(
            symbolName: "Baby/Child",
            category: .object,
            percentageOfDreamers: 35,
            topMeaning: "New beginnings or inner child",
            interpretations: [
                Interpretation(meaning: "New projects/ideas", frequency: 40, emotionalTag: "Hope"),
                Interpretation(meaning: "Inner child/nurturing", frequency: 30, emotionalTag: "Joy"),
                Interpretation(meaning: " Innocence", frequency: 15, emotionalTag: "Peace"),
                Interpretation(meaning: "Responsibility concerns", frequency: 15, emotionalTag: "Anxiety")
            ]
        )
    ]

    // MARK: - Symbol of the Day

    func getSymbolOfTheDay(userSymbols: [Symbol]) -> CommunityPattern? {
        // If user has symbols, pick one that matches community patterns
        let userSymbolNames = Set(userSymbols.map { $0.name.lowercased() })
        let matchingPatterns = mockPatterns.filter { userSymbolNames.contains($0.symbolName.lowercased()) }

        if let match = matchingPatterns.randomElement() {
            return match
        }

        // Otherwise pick based on day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return mockPatterns[dayOfYear % mockPatterns.count]
    }

    // MARK: - Get Patterns

    func getPatterns(for category: SymbolCategory? = nil) -> [CommunityPattern] {
        if let category = category {
            return mockPatterns.filter { $0.category == category }
        }
        return mockPatterns
    }

    func getPattern(for symbolName: String) -> CommunityPattern? {
        mockPatterns.first { $0.symbolName.lowercased() == symbolName.lowercased() }
    }

    // MARK: - Search Patterns

    func searchPatterns(query: String) -> [CommunityPattern] {
        let lowercased = query.lowercased()
        return mockPatterns.filter {
            $0.symbolName.lowercased().contains(lowercased) ||
            $0.topMeaning.lowercased().contains(lowercased)
        }
    }

    // MARK: - Anonymous Submission (mock)

    func submitSymbolAnonymously(
        symbolName: String,
        category: SymbolCategory,
        context: String,
        completion: @escaping (AnonymousSymbolSubmission?) -> Void
    ) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let pattern = self.getPattern(for: symbolName)

            let submission = AnonymousSymbolSubmission(
                id: UUID(),
                symbolName: symbolName,
                category: category,
                dreamContext: context,
                submittedAt: Date(),
                communityPercentage: pattern?.percentageOfDreamers ?? Int.random(in: 20...60),
                topInterpretation: pattern?.topMeaning ?? "A personal symbol unique to your dream journey",
                relatedEmotions: pattern?.interpretations.prefix(2).map { $0.emotionalTag } ?? ["Mystery"]
            )

            completion(submission)
        }
    }

    // MARK: - Interpretation Help

    func getInterpretationHelp(for symbolName: String) -> [Interpretation] {
        getPattern(for: symbolName)?.interpretations ?? [
            Interpretation(meaning: "A personal symbol — only you hold its true meaning", frequency: 100, emotionalTag: "Mystery")
        ]
    }
}
