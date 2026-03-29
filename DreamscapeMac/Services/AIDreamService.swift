import Foundation
import NaturalLanguage

// MARK: - DreamEntry Alias
// DreamEntry maps to Dream for compatibility with existing models
typealias DreamEntry = Dream

// MARK: - AIDreamService
/// On-device AI service for dream interpretation using Apple frameworks.
/// Uses NaturalLanguage for symbol extraction and contextual analysis.
final class AIDreamService: @unchecked Sendable {
    nonisolated(unsafe) static let shared = AIDreamService()

    private let tagger: NLTagger
    private let sentimentTagger: NLTagger

    // Common dream symbol interpretations
    private let symbolInterpretations: [String: [String]] = [
        "water": ["emotional state", "subconscious mind", "purification", "intuition"],
        "ocean": ["deep emotions", "the unconscious", "boundless possibility", "isolation"],
        "flight": ["desire for freedom", "ambition", "escaping constraints", " transcendence"],
        "falling": ["loss of control", "anxiety", "insecurity", "letting go"],
        "house": ["psyche", "self", "different aspects of personality", " life stages"],
        "forest": ["unknown aspects", "nature", "feeling lost", "growth"],
        "fire": ["passion", "anger", "transformation", "purification"],
        "moon": ["intuition", "femininity", "cycles", "subconscious"],
        "stars": ["aspiration", "hope", "guidance", "dreams themselves"],
        "bird": ["freedom", " perspective", "spiritual messenger", "thoughts"],
        "snake": ["transformation", "wisdom", "hidden fears", "life force"],
        "mountain": ["obstacles", "achievement", "spiritual growth", " perspective"],
        "river": ["life flow", "time passage", "emotional journey", " continuity"],
        "city": ["social self", "external world", "connections", "complexity"],
        "mirror": ["self-reflection", "truth", "identity", " how you see yourself"],
        "road": ["life path", "choices", "direction", " journey"],
        "door": ["opportunity", "transition", "secrets", " new beginnings"],
        "child": ["inner child", "innocence", "potential", " playfulness"],
        "death": ["endings", "transformation", "change", " fear of the unknown"],
        "car": ["control", "direction in life", "personal drive", " independence"],
        "train": ["life direction", "unexpected changes", " collective journey"],
        "plane": ["ambition", "elevation", "long-distance travel", " aspiration"],
        "bridge": ["transition", "connection", "overcoming obstacles", " adaptation"],
        "animal": ["instincts", "inner nature", "animalistic urges", "companionship"],
        "cat": ["independence", "mystery", "feminine energy", "intuition"],
        "dog": ["loyalty", "friendship", "protection", " unconditional love"],
        "horse": ["power", "freedom", "drive", " emotional energy"],
        "wolf": ["wild nature", "intuition", "loneliness", " strength"],
        "library": ["knowledge", "memory", "search for truth", " hidden wisdom"],
        "school": ["learning", "growth", "social structures", " evaluation"],
        "prison": ["restriction", "self-imposed limits", "guilt", " isolation"],
        "beach": ["transition", "emotional boundary", "recreation", " perspective"],
        "cave": ["inner self", "the unknown", "hidden fears", " introspection"],
        "castle": ["ambition", "protection", "status", " inner fortress"],
        "garden": ["growth", "nature", "spirituality", " cultivation of self"],
        "tree": ["life", "growth", "development", " grounding"],
        "flower": ["beauty", "transformation", "emotions", " renewal"],
        "rain": ["emotional release", "cleansing", "sadness", " renewal"],
        "storm": ["turbulence", "emotional upheaval", "change", " inner conflict"],
        "snow": ["isolation", "purity", "dormancy", " emotional coldness"],
        "wind": ["change", "breath", "spiritual influence", " freedom"],
        "light": ["consciousness", "truth", "hope", " enlightenment"],
        "darkness": ["unknown", "fear", "hidden aspects", " unconscious"],
        "shadow": ["hidden self", "subconscious", "repressed aspects", " integration"],
        "ghost": ["past", "unfinished business", "fear", " lingering emotions"],
        "monster": ["repressed fears", "inner conflicts", "danger", " shadow self"],
        "monkey": ["mischief", "curiosity", "playfulness", " adaptability"]
    ]

    // Theme patterns
    private let themePatterns: [String: [String]] = [
        "freedom": ["flying", "bird", "open sky", "wings", "soaring", "escape"],
        "fear": ["chase", "monster", "darkness", "falling", "trapped", "unable to move"],
        "transformation": ["snake", "metamorphosis", "changing", "becoming", "morph"],
        "love": ["embrace", "heart", "kiss", "romantic", "partner", "together"],
        "loss": ["death", "funeral", "leaving", "gone", "empty", "alone"],
        "growth": ["tree", "flower", "garden", "bloom", "ascending", "rising"],
        "conflict": ["fight", "battle", "argument", "struggle", "opponent", "war"],
        "mystery": ["hidden", "secret", "unknown", "strange", "puzzle", "discover"],
        "journey": ["road", "path", "travel", "destination", "map", "adventure"]
    ]

    init() {
        tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .lemma])
        sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
    }

    // MARK: - Public API

    /// Interpret a dream and provide comprehensive analysis
    func interpretDream(_ dream: DreamEntry) -> DreamInterpretation {
        let narrative = dream.narrative.lowercased()
        
        // Extract components
        let themes = extractThemes(from: narrative)
        let symbols = extractDreamSymbols(from: narrative, allSymbols: dream.detectedSymbols)
        let emotionalArc = analyzeEmotionalArc(narrative)
        let lucidityScore = estimateLucidity(narrative, reportedLevel: dream.lucidityLevel)
        let summary = generateInterpretation(for: dream, themes: themes, symbols: symbols)

        return DreamInterpretation(
            summary: summary,
            themes: themes,
            symbols: symbols,
            emotionalArc: emotionalArc,
            lucidityScore: lucidityScore
        )
    }

    /// Get contextual interpretation for a specific symbol
    func interpretSymbol(_ symbolName: String, inContextOf dreams: [DreamEntry]) -> String {
        let lowercased = symbolName.lowercased()
        
        // Count occurrences
        let count = dreams.filter {
            $0.narrative.lowercased().contains(lowercased)
        }.count

        // Get standard interpretations
        let baseInterpretations = symbolInterpretations[lowercased] ?? ["personal symbol unique to your dream world"]

        // Build contextual message
        let frequencyContext: String
        if count > 10 {
            frequencyContext = "A recurring presence in your dreamscape."
        } else if count > 5 {
            frequencyContext = "Appearing with notable frequency."
        } else if count > 1 {
            frequencyContext = "Seen a few times in your journey."
        } else {
            frequencyContext = "A rare visitor to your dreams."
        }

        let interpretation = baseInterpretations.joined(separator: " or ")
        return "\(frequencyContext) Typically represents \(interpretation)."
    }

    // MARK: - Private Methods

    private func extractThemes(from text: String) -> [String] {
        var detectedThemes: [String] = []

        for (theme, keywords) in themePatterns {
            let matches = keywords.filter { text.contains($0) }.count
            if matches >= 1 {
                detectedThemes.append(theme.capitalized)
            }
        }

        // Add mood-based theme
        if text.contains("peaceful") || text.contains("calm") || text.contains("serene") {
            if !detectedThemes.contains("Peace") {
                detectedThemes.append("Peace")
            }
        }

        // Limit to top 5 themes
        return Array(detectedThemes.prefix(5))
    }

    private func extractDreamSymbols(from text: String, allSymbols: [String]) -> [DreamSymbol] {
        var symbols: [DreamSymbol] = []

        // Process known symbols
        for symbolName in allSymbols {
            let lowercased = symbolName.lowercased()
            
            // Determine category based on keyword matching
            let category: DreamSymbol.Category
            let emotionKeywords = ["fear", "joy", "sad", "happy", "angry", "peace", "love", "hate", "anxious", "calm"]
            let elementKeywords = ["water", "fire", "earth", "air", "wind", "storm", "rain", "snow", "ocean", "river"]
            let placeKeywords = ["house", "city", "forest", "beach", "mountain", "room", "building", "garden"]
            let animalKeywords = ["dog", "cat", "bird", "snake", "horse", "wolf", "fish", "butterfly", "monkey"]

            if emotionKeywords.contains(where: { lowercased.contains($0) }) {
                category = .emotion
            } else if elementKeywords.contains(where: { lowercased.contains($0) }) {
                category = .element
            } else if placeKeywords.contains(where: { lowercased.contains($0) }) {
                category = .place
            } else if animalKeywords.contains(where: { lowercased.contains($0) }) {
                category = .animal
            } else if text.contains(lowercased) {
                category = .object
            } else {
                category = .object
            }

            // Generate mini interpretation
            let interpretation = symbolInterpretations[lowercased]?.first ?? "A meaningful symbol in your dream narrative."

            symbols.append(DreamSymbol(
                name: symbolName.capitalized,
                category: category,
                occurrenceCount: 1,
                lastAppeared: Date()
            ))
        }

        // Use NL to extract named entities as additional symbols
        tagger.string = text
        let range = text.startIndex..<text.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: [.omitWhitespace, .omitPunctuation]) { tag, tokenRange in
            if let tag = tag, tag == .personalName || tag == .placeName || tag == .organizationName {
                let entity = String(text[tokenRange]).capitalized
                if !symbols.contains(where: { $0.name.lowercased() == entity.lowercased() }) {
                    let category: DreamSymbol.Category = tag == .personalName ? .person : .place
                    symbols.append(DreamSymbol(
                        name: entity,
                        category: category,
                        occurrenceCount: 1,
                        lastAppeared: Date()
                    ))
                }
            }
            return true
        }

        return symbols
    }

    private func analyzeEmotionalArc(_ text: String) -> String {
        sentimentTagger.string = text

        let (sentiment, _) = sentimentTagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let score = Double(sentiment?.rawValue ?? "0") ?? 0

        // Analyze emotional trajectory
        let emotionalIndicators = analyzeEmotionalIndicators(text)

        if score > 0.5 {
            return "Uplifting journey through \(emotionalIndicators). The dream carries positive energy and hope."
        } else if score < -0.3 {
            return "Exploration of \(emotionalIndicators). The dream touches on challenging emotions and deep processing."
        } else {
            return "Contemplative exploration of \(emotionalIndicators). A balanced journey through your subconscious landscape."
        }
    }

    private func analyzeEmotionalIndicators(_ text: String) -> String {
        let positiveWords = ["peace", "joy", "love", "happy", "beautiful", "wonderful", "bright", "warm", "safe"]
        let negativeWords = ["fear", "dark", "sad", "angry", "scared", "anxious", "chase", "trapped", "lost"]
        let neutralWords = ["observe", "watch", "see", "notice", "explore", "wander"]

        let words = text.lowercased().split(separator: " ").map { String($0) }
        var posCount = 0, negCount = 0, neuCount = 0

        for word in words {
            if positiveWords.contains(where: { word.contains($0) }) { posCount += 1 }
            if negativeWords.contains(where: { word.contains($0) }) { negCount += 1 }
            if neutralWords.contains(where: { word.contains($0) }) { neuCount += 1 }
        }

        if posCount > negCount {
            return "bright horizons and positive emotions"
        } else if negCount > posCount {
            return "shadows and challenging terrain"
        } else {
            return "mysterious landscapes and quiet introspection"
        }
    }

    private func estimateLucidity(_ text: String, reportedLevel: Int) -> Int {
        // Lucidity indicators in dream narrative
        let lucidityKeywords = [
            "realize", "realized", "aware", "knowing", "conscious",
            "this is a dream", "i'm dreaming", "lucid", "control",
            "i can fly", "i chose", "i decided", "notice myself",
            "watching myself", "observer", "witness"
        ]

        var score = reportedLevel
        let lowercased = text.lowercased()

        for keyword in lucidityKeywords {
            if lowercased.contains(keyword) {
                score = max(score, min(5, score + 1))
            }
        }

        return min(5, max(1, score))
    }

    private func generateInterpretation(for dream: DreamEntry, themes: [String], symbols: [DreamSymbol]) -> String {
        var parts: [String] = []

        // Opening based on mood and themes
        if let firstTheme = themes.first {
            parts.append("This \(dream.mood.rawValue.lowercased()) dream explores themes of \(firstTheme.lowercased()).")
        } else {
            parts.append("A vivid \(dream.mood.rawValue.lowercased()) dream from your subconscious.")
        }

        // Symbol insights
        if let topSymbol = symbols.first {
            let symbolContext = interpretSymbol(topSymbol.name, inContextOf: [dream])
            let cleanContext = symbolContext.replacingOccurrences(of: "A recurring presence in your dreamscape.", with: "")
                .replacingOccurrences(of: "A rare visitor to your dreams.", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanContext.isEmpty && !cleanContext.hasPrefix("Typically") == false {
                if cleanContext.hasPrefix("Typically") {
                    parts.append("The presence of \(topSymbol.name.lowercased()) is significant: \(cleanContext)")
                }
            }
        }

        // Lucidity insight
        if dream.lucidityLevel >= 4 {
            parts.append("Your high lucidity (\(dream.lucidityLevel)/5) indicates strong dream awareness.")
        } else if dream.lucidityLevel >= 2 {
            parts.append("With moderate lucidity, this dream offers valuable subconscious insight.")
        }

        // Closing
        parts.append("Continue journaling to track patterns and deepen your self-understanding.")

        return parts.joined(separator: " ")
    }
}

// MARK: - DreamInterpretation
extension AIDreamService {
    struct DreamInterpretation: Equatable {
        let summary: String
        let themes: [String]
        let symbols: [DreamSymbol]
        let emotionalArc: String
        let lucidityScore: Int

        static let empty = DreamInterpretation(
            summary: "",
            themes: [],
            symbols: [],
            emotionalArc: "",
            lucidityScore: 1
        )
    }
}
