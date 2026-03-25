import Foundation
import NaturalLanguage

@MainActor
final class DreamAnalysisService {
    static let shared = DreamAnalysisService()

    private let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])

    private init() {}

    func analyzeDream(_ text: String) async -> DreamAnalysisResult {
        let symbols = extractSymbols(from: text)
        let summary = generateSummary(from: text, symbols: symbols)
        let themes = detectThemes(from: text)
        let emotionalTags = extractEmotionalTags(from: text)
        let emotionalJourney = analyzeEmotionalJourney(from: text)
        let shadowWorkPrompts = generateShadowWorkPrompts(symbols: symbols, themes: themes, emotionalTags: emotionalTags)
        let integrationSuggestion = generateIntegrationSuggestion(dreamText: text, symbols: symbols, themes: themes, emotionalTags: emotionalTags)
        let narrativeArc = analyzeNarrativeArc(from: text)

        return DreamAnalysisResult(
            symbols: symbols,
            summary: summary,
            themes: themes,
            emotionalTags: emotionalTags,
            emotionalJourney: emotionalJourney,
            shadowWorkPrompts: shadowWorkPrompts,
            integrationSuggestion: integrationSuggestion,
            narrativeArc: narrativeArc
        )
    }

    /// Deep analysis: emotional journey through the dream
    func analyzeEmotionalJourney(from text: String) -> [EmotionalJourneySegment] {
        // Split dream into segments and analyze emotions per segment
        let segments = splitIntoSegments(text)
        return segments.enumerated().map { index, segment in
            let emotions = extractEmotionalKeywords(from: segment)
            let dominantEmotion = emotions.first ?? "Neutral"
            let intensity = estimateEmotionIntensity(segment, emotion: dominantEmotion)

            return EmotionalJourneySegment(
                order: index + 1,
                segmentText: String(segment.prefix(100)) + (segment.count > 100 ? "..." : ""),
                dominantEmotion: dominantEmotion,
                intensity: intensity
            )
        }
    }

    /// Narrative arc: beginning, middle, end analysis
    func analyzeNarrativeArc(from text: String) -> NarrativeArc {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmed }
            .filter { !$0.isEmpty }

        let third = max(1, sentences.count / 3)
        let beginning = sentences.prefix(third).joined(separator: ". ")
        let middleCount = max(0, sentences.count - third * 2)
        let middle = sentences.dropFirst(third).prefix(third).joined(separator: ". ")
        let end = sentences.suffix(middleCount).joined(separator: ". ")

        let arcType = determineArcType(beginning: beginning, middle: middle, end: end, totalSentences: sentences.count)

        return NarrativeArc(
            beginning: beginning.isEmpty ? nil : beginning,
            middle: middle.isEmpty ? nil : middle,
            end: end.isEmpty ? nil : end,
            arcType: arcType,
            totalSegments: sentences.count
        )
    }

    /// Shadow work prompts: AI surfaces unconscious patterns
    func generateShadowWorkPrompts(symbols: [Symbol], themes: [String], emotionalTags: [String]) -> [ShadowWorkPrompt] {
        var prompts: [ShadowWorkPrompt] = []

        // Pattern-based prompts
        if themes.contains("Pursuit") {
            prompts.append(ShadowWorkPrompt(
                category: .shadow,
                question: "What or who are you chasing in waking life? What would happen if you stopped?",
                relatedSymbol: symbols.first { $0.category == .place }?.name,
                theme: "Pursuit"
            ))
        }

        if themes.contains("Flying") {
            prompts.append(ShadowWorkPrompt(
                category: .shadow,
                question: "Where in your life do you desire freedom or escape? What holds you back from soaring?",
                relatedSymbol: "Flight",
                theme: "Freedom"
            ))
        }

        if themes.contains("Water") {
            prompts.append(ShadowWorkPrompt(
                category: .shadow,
                question: "What emotions have you been avoiding or trying to suppress? Water in dreams often represents the unconscious.",
                relatedSymbol: "Water",
                theme: "Water"
            ))
        }

        if themes.contains("Death") {
            prompts.append(ShadowWorkPrompt(
                category: .transformation,
                question: "What part of yourself or your life needs to end for something new to begin?",
                relatedSymbol: "Death",
                theme: "Death & Rebirth"
            ))
        }

        // Emotion-based prompts
        for tag in emotionalTags.prefix(2) {
            prompts.append(ShadowWorkPrompt(
                category: .integration,
                question: "How do you relate to the feeling of \(tag.lowercased()) in your dreams? Do you allow yourself to feel this in waking life?",
                relatedSymbol: nil,
                theme: tag
            ))
        }

        // Symbol-based prompts
        for symbol in symbols.prefix(2) {
            prompts.append(ShadowWorkPrompt(
                category: .exploration,
                question: "What does '\(symbol.name)' mean to you personally? Where does this association come from?",
                relatedSymbol: symbol.name,
                theme: symbol.category.rawValue.capitalized
            ))
        }

        return prompts
    }

    /// Integration suggestion: what the dream might be asking of you
    func generateIntegrationSuggestion(dreamText: String, symbols: [Symbol], themes: [String], emotionalTags: [String]) -> String {
        var suggestions: [String] = []

        if themes.contains("Flight") {
            suggestions.append("This dream invites you to claim more freedom in your waking life. Where have you been playing it small?")
        }

        if themes.contains("Water") {
            suggestions.append("Pay attention to your emotional landscape. The dream suggests hidden feelings surfacing.")
        }

        if themes.contains("Pursuit") {
            suggestions.append("Ask yourself: what are you truly running toward, not just running from?")
        }

        if themes.contains("Family") {
            suggestions.append("Your inner child may be asking for attention. What childhood patterns still influence your present?")
        }

        if emotionalTags.contains("Fear") {
            suggestions.append("Face what scares you. Dreams of fear often point to growth opportunities at the edge of your comfort zone.")
        }

        if emotionalTags.contains("Love") {
            suggestions.append("Love is emerging in your psyche. Where can you open your heart more fully today?")
        }

        if !symbols.isEmpty {
            let symbolNames = symbols.prefix(2).map { $0.name }.joined(separator: " and ")
            suggestions.append("Notice how '\(symbolNames)' appear in your waking life this week. What connections do you see?")
        }

        if suggestions.isEmpty {
            return "Take a moment to sit with this dream. What feeling lingers? Let that feeling guide your reflections today."
        }

        return suggestions.joined(separator: "\n\n")
    }

    /// Refine a dream incubation intention using AI-like prompting
    func refineIncubationIntention(_ intention: String) async -> String {
        // Simulate AI refinement by identifying keywords and suggesting framing
        let keywords = intention.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }

        if keywords.contains("flying") || keywords.contains("flight") {
            return "\(intention) — Open yourself to dreams of soaring above your current perspective, showing you the bigger picture of your life."
        }
        if keywords.contains("water") || keywords.contains("ocean") {
            return "\(intention) — Invite dreams that explore your emotional depths and unconscious wisdom."
        }
        if keywords.contains("animal") {
            return "\(intention) — Allow your instinctual nature to communicate through animal dream symbols."
        }
        if keywords.contains("family") || keywords.contains("home") {
            return "\(intention) — Explore themes of belonging, home, and your relationship with family patterns."
        }

        return "Tonight I dream about \(intention). I am open to understanding what this means for my growth and well-being."
    }

    private func extractSymbols(from text: String) -> [Symbol] {
        var extractedSymbols: [Symbol] = []
        var seenNames: Set<String> = []

        tagger.string = text
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            guard let tag = tag else { return true }

            let name = String(text[range])
            let lowercased = name.lowercased()

            // Skip common/less meaningful words
            guard !isCommonWord(lowercased),
                  !seenNames.contains(lowercased) else { return true }

            seenNames.insert(lowercased)

            let category = categorizeEntity(tag, word: lowercased)
            let symbol = Symbol(
                name: name.capitalized,
                category: category,
                frequency: 1
            )
            extractedSymbols.append(symbol)

            return true
        }

        // Also extract emotional keywords
        let emotionalKeywords = extractEmotionalKeywords(from: text)
        for emotion in emotionalKeywords {
            if !seenNames.contains(emotion.lowercased()) {
                extractedSymbols.append(Symbol(
                    name: emotion.capitalized,
                    category: .emotion,
                    frequency: 1
                ))
            }
        }

        return Array(extractedSymbols.prefix(10)) // Limit to 10 symbols
    }

    private func isCommonWord(_ word: String) -> Bool {
        let commonWords: Set<String> = [
            "the", "a", "an", "is", "was", "were", "are", "be", "been", "being",
            "have", "has", "had", "do", "does", "did", "will", "would", "could",
            "should", "may", "might", "must", "shall", "can", "need", "dare",
            "ought", "used", "to", "from", "in", "out", "on", "off", "over",
            "under", "again", "further", "then", "once", "here", "there", "when",
            "where", "why", "how", "all", "each", "few", "more", "most", "other",
            "some", "such", "no", "nor", "not", "only", "own", "same", "so",
            "than", "too", "very", "just", "and", "but", "if", "or", "because",
            "as", "until", "while", "of", "at", "by", "for", "with", "about",
            "against", "between", "into", "through", "during", "before", "after",
            "above", "below", "up", "down", "i", "me", "my", "myself", "we",
            "our", "ours", "ourselves", "you", "your", "yours", "yourself",
            "yourselves", "he", "him", "his", "himself", "she", "her", "hers",
            "herself", "it", "its", "itself", "they", "them", "their", "theirs",
            "themselves", "what", "which", "who", "whom", "this", "that", "these",
            "those", "am", "dream", "dreams", "felt", "feel", "feeling"
        ]
        return commonWords.contains(word) || word.count < 3
    }

    private func categorizeEntity(_ tag: NLTag, word: String) -> SymbolCategory {
        switch tag {
        case .personalName:
            return .person
        case .placeName:
            return .place
        case .organizationName:
            return .place
        default:
            // Check if it's likely an object
            if isObjectKeyword(word) {
                return .object
            }
            return .place
        }
    }

    private func isObjectKeyword(_ word: String) -> Bool {
        let objectKeywords: Set<String> = [
            "car", "house", "building", "door", "window", "table", "chair", "bed",
            "phone", "computer", "book", "clock", "mirror", "key", "knife",
            "animal", "bird", "fish", "dog", "cat", "horse", "tree", "flower",
            "water", "fire", "stone", "rock", "mountain", "cloud", "moon", "star",
            "sun", "rain", "snow", "wind", "storm", "light", "darkness", "shadow"
        ]
        return objectKeywords.contains(word)
    }

    private func extractEmotionalTags(from text: String) -> [String] {
        extractEmotionalKeywords(from: text)
    }

    private func extractEmotionalKeywords(from text: String) -> [String] {
        let emotionKeywords: [(keywords: [String], emotion: String)] = [
            (["happy", "joy", "joyful", "excited", "delighted", "cheerful", "glad", "pleased", "thrilled", "ecstatic"], "Happiness"),
            (["sad", "sadness", "unhappy", "depressed", "gloomy", "melancholy", "down", "blue", "crying", "tears"], "Sadness"),
            (["afraid", "fear", "scared", "terrified", "frightened", "anxious", "worried", "nervous", "panic", "horror"], "Fear"),
            (["angry", "mad", "furious", "rage", "annoyed", "irritated", "frustrated", "enraged"], "Anger"),
            (["love", "loving", "loved", "affection", "warm", "tender", "caring", "romantic", "passion"], "Love"),
            (["peace", "peaceful", "calm", "serene", "tranquil", "relaxed", "at ease", "restful"], "Peace"),
            (["confused", "confusion", "lost", "uncertain", "puzzled", "disoriented", "bewildered"], "Confusion"),
            (["flying", "fly", "flight", "flew", " soaring", "ascending", "levitation", "free"], "Freedom"),
            (["chase", "chasing", "running", "escape", "escaping", "fleeing", "pursuit", "running away"], "Pursuit"),
            (["falling", "fall", "dropped", "descending", "tumbling"], "Falling")
        ]

        var foundEmotions: [String] = []
        let lowercasedText = text.lowercased()

        for (keywords, emotion) in emotionKeywords {
            for keyword in keywords {
                if lowercasedText.contains(keyword) && !foundEmotions.contains(emotion) {
                    foundEmotions.append(emotion)
                    break
                }
            }
        }

        return foundEmotions
    }

    private func generateSummary(from text: String, symbols: [Symbol]) -> String {
        // Simple extractive summarization
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmed }
            .filter { !$0.isEmpty }

        if sentences.isEmpty {
            return "A dream unfolds..."
        }

        // Take first 2 sentences as summary, truncated
        let summarySentences = Array(sentences.prefix(2))
        var summary = summarySentences.joined(separator: ". ")

        if !summary.isEmpty && !summary.hasSuffix(".") {
            summary += "."
        }

        return summary.isEmpty ? "A dream unfolds..." : summary
    }

    private func detectThemes(from text: String) -> [String] {
        let themePatterns: [(pattern: String, theme: String)] = [
            ("flying|flight|soaring|levitation|ascending", "Flight"),
            ("falling|descending|tumbling|dropping", "Falling"),
            ("chase|chasing|pursuit|running away|fleeing", "Pursuit"),
            ("water|ocean|sea|river|lake|swimming|diving|underwater", "Water"),
            ("fire|flame|burning|wildfire|inferno", "Fire"),
            ("death|dying|grave|funeral|coffin|ghost|spirit", "Death"),
            ("school|classroom|exam|teacher|college|university", "School"),
            ("work|office|job|coworker|boss|meeting", "Work"),
            ("home|house|family|parent|child|sibling|mother|father", "Family"),
            ("animal|bird|dog|cat|wolf|bear|snake|insect", "Animals"),
            ("monster|creature|beast|alien|extraterrestrial", "Monster"),
            ("lost|missing|trapped|stuck|unable to move", "Trapped"),
            ("naked|undressed|exposed|embarrassed", "Nakedness")
        ]

        var detectedThemes: [String] = []
        let lowercasedText = text.lowercased()

        for (pattern, theme) in themePatterns {
            if lowercasedText.range(of: pattern, options: .regularExpression) != nil {
                detectedThemes.append(theme)
            }
        }

        return detectedThemes
    }

    private func splitIntoSegments(_ text: String) -> [String] {
        // Split by sentence boundaries and group into ~3 segments
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmed }
            .filter { !$0.isEmpty }

        guard !sentences.isEmpty else { return [text] }

        let third = max(1, sentences.count / 3)
        var segments: [String] = []

        segments.append(sentences.prefix(third).joined(separator: ". "))
        if sentences.count > third {
            segments.append(sentences.dropFirst(third).prefix(third).joined(separator: ". "))
        }
        if sentences.count > third * 2 {
            segments.append(sentences.suffix(sentences.count - third * 2).joined(separator: ". "))
        }

        return segments.isEmpty ? [text] : segments
    }

    private func estimateEmotionIntensity(_ text: String, emotion: String) -> Double {
        let lowercased = text.lowercased()
        let emotionKeywords: [String: [String]] = [
            "Happiness": ["very happy", "ecstatic", "overjoyed", "thrilled", "delighted"],
            "Sadness": ["very sad", "devastated", "heartbroken", "weeping", "tears"],
            "Fear": ["terrified", "horrified", "panicked", "absolutely terrified", "screaming"],
            "Anger": ["furious", "enraged", "rage", "livid", "seething"],
            "Love": ["deeply loved", "overwhelming love", "deeply connected", "intensely loved"],
            "Peace": ["completely calm", "utterly peaceful", "deeply serene", "totally at peace"],
            "Confusion": ["completely lost", "totally confused", "utterly disoriented", "deeply puzzled"]
        ]

        let keywords = emotionKeywords[emotion] ?? []
        var intensity: Double = 0.5

        for keyword in keywords {
            if lowercased.contains(keyword) {
                intensity = min(1.0, intensity + 0.2)
            }
        }

        // Check for intensity modifiers
        if lowercased.contains("very") || lowercased.contains("really") || lowercased.contains("extremely") {
            intensity = min(1.0, intensity + 0.15)
        }

        return intensity
    }

    private func determineArcType(beginning: String, middle: String, end: String, totalSentences: Int) -> String {
        let lowercased = end.lowercased()

        // Resolution arc
        if lowercased.contains("woke up") || lowercased.contains("awoke") {
            return "Awakening"
        }
        // Challenge arc
        if middle.contains("chase") || middle.contains("run") || middle.contains("escape") {
            return "Challenge"
        }
        // Transformation arc
        if lowercased.contains("changed") || lowercased.contains("became") || lowercased.contains("transformed") {
            return "Transformation"
        }
        // Return arc (returning to origin)
        if beginning.lowercased() == end.lowercased() {
            return "Return"
        }
        // Discovery arc
        if lowercased.contains("found") || lowercased.contains("discovered") || lowercased.contains("realized") {
            return "Discovery"
        }

        return totalSentences <= 5 ? "Moment" : "Narrative"
    }
}

struct DreamAnalysisResult {
    let symbols: [Symbol]
    let summary: String
    let themes: [String]
    let emotionalTags: [String]
    var emotionalJourney: [EmotionalJourneySegment]
    var shadowWorkPrompts: [ShadowWorkPrompt]
    var integrationSuggestion: String
    var narrativeArc: NarrativeArc

    init(
        symbols: [Symbol],
        summary: String,
        themes: [String],
        emotionalTags: [String],
        emotionalJourney: [EmotionalJourneySegment] = [],
        shadowWorkPrompts: [ShadowWorkPrompt] = [],
        integrationSuggestion: String = "",
        narrativeArc: NarrativeArc = NarrativeArc()
    ) {
        self.symbols = symbols
        self.summary = summary
        self.themes = themes
        self.emotionalTags = emotionalTags
        self.emotionalJourney = emotionalJourney
        self.shadowWorkPrompts = shadowWorkPrompts
        self.integrationSuggestion = integrationSuggestion
        self.narrativeArc = narrativeArc
    }
}

struct EmotionalJourneySegment: Identifiable {
    let id = UUID()
    let order: Int
    let segmentText: String
    let dominantEmotion: String
    let intensity: Double // 0.0 to 1.0
}

struct NarrativeArc {
    let beginning: String?
    let middle: String?
    let end: String?
    let arcType: String
    let totalSegments: Int

    init(beginning: String? = nil, middle: String? = nil, end: String? = nil, arcType: String = "Narrative", totalSegments: Int = 0) {
        self.beginning = beginning
        self.middle = middle
        self.end = end
        self.arcType = arcType
        self.totalSegments = totalSegments
    }
}

enum ShadowWorkCategory: String, Codable {
    case shadow = "Shadow Work"
    case integration = "Integration"
    case exploration = "Exploration"
    case transformation = "Transformation"
}

struct ShadowWorkPrompt: Identifiable {
    let id = UUID()
    let category: ShadowWorkCategory
    let question: String
    let relatedSymbol: String?
    let theme: String
}
