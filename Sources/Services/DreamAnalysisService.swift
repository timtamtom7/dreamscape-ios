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

        return DreamAnalysisResult(
            symbols: symbols,
            summary: summary,
            themes: themes
        )
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
}

struct DreamAnalysisResult {
    let symbols: [Symbol]
    let summary: String
    let themes: [String]
}
