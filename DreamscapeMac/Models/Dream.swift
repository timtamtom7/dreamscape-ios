import Foundation

struct Dream: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var narrative: String
    var date: Date
    var mood: Mood
    var lucidityLevel: Int // 1-5
    var tags: [String]
    var summary: String?
    var detectedSymbols: [String]
    var isAnalyzed: Bool

    init(
        id: UUID = UUID(),
        title: String,
        narrative: String,
        date: Date = Date(),
        mood: Mood = .neutral,
        lucidityLevel: Int = 1,
        tags: [String] = [],
        summary: String? = nil,
        detectedSymbols: [String] = [],
        isAnalyzed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.narrative = narrative
        self.date = date
        self.mood = mood
        self.lucidityLevel = lucidityLevel
        self.tags = tags
        self.summary = summary
        self.detectedSymbols = detectedSymbols
        self.isAnalyzed = isAnalyzed
    }

    enum Mood: String, Codable, CaseIterable, Identifiable {
        case peaceful = "Peaceful"
        case adventurous = "Adventurous"
        case anxious = "Anxious"
        case mysterious = "Mysterious"
        case joyful = "Joyful"
        case dark = "Dark"
        case romantic = "Romantic"
        case confusing = "Confusing"
        case neutral = "Neutral"

        var id: String { rawValue }

        var emoji: String {
            switch self {
            case .peaceful: return "😌"
            case .adventurous: return "🧭"
            case .anxious: return "😰"
            case .mysterious: return "🔮"
            case .joyful: return "🌟"
            case .dark: return "🌑"
            case .romantic: return "💫"
            case .confusing: return "🌀"
            case .neutral: return "🌙"
            }
        }

        var color: String {
            switch self {
            case .peaceful: return "5EEAD4"
            case .adventurous: return "F59E0B"
            case .anxious: return "F87171"
            case .mysterious: return "C084FC"
            case .joyful: return "FCD34D"
            case .dark: return "6366F1"
            case .romantic: return "EC4899"
            case .confusing: return "8B8BA7"
            case .neutral: return "A0A0B0"
            }
        }
    }
}

extension Dream {
    static let sample = Dream(
        title: "Flying Over a Purple Ocean",
        narrative: "I was soaring above a vast purple ocean under a starlit sky. The water was warm and reflected the constellations above. I felt completely at peace, aware that I was dreaming and savoring every moment of flight.",
        date: Date(),
        mood: .peaceful,
        lucidityLevel: 4,
        tags: ["flying", "ocean", "stars", "lucidity"],
        summary: "A lucid flying dream over a cosmic purple sea, symbolizing freedom and emotional peace.",
        detectedSymbols: ["ocean", "stars", "flight", "moon"],
        isAnalyzed: true
    )

    static let samples: [Dream] = [
        sample,
        Dream(
            title: "The Infinite Library",
            narrative: "I wandered through an endless library where each book contained a different version of my life. The shelves stretched into infinity, lit by floating candles.",
            date: Date().addingTimeInterval(-86400),
            mood: .mysterious,
            lucidityLevel: 3,
            tags: ["library", "books", "infinity"],
            summary: "Exploration of an infinite library representing the search for knowledge and self-understanding.",
            detectedSymbols: ["books", "candles", "infinity"],
            isAnalyzed: true
        ),
        Dream(
            title: "City of Glass",
            narrative: "I walked through a city made entirely of glass. Everything was transparent and I could see everyone's thoughts floating like bubbles around them.",
            date: Date().addingTimeInterval(-172800),
            mood: .anxious,
            lucidityLevel: 2,
            tags: ["city", "glass", "transparency", "thoughts"],
            summary: "A dream about vulnerability and the fear of being truly seen by others.",
            detectedSymbols: ["city", "glass", "thoughts"],
            isAnalyzed: true
        )
    ]
}
