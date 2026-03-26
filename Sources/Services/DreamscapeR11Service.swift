import Foundation

// R11: Dream Journal, Visualization, Community for Dreamscape
@MainActor
final class DreamscapeR11Service: ObservableObject {
    static let shared = DreamscapeR11Service()

    @Published var dreamGallery: [DreamVisualization] = []

    private init() {}

    // MARK: - Dream Journal

    struct DreamEntry: Identifiable, Codable {
        let id: UUID
        var title: String
        var content: String
        var recordedAt: Date
        var quality: DreamQuality
        var isLucid: Bool
        var symbols: [String]

        enum DreamQuality: Int, Codable {
            case vague = 1
            case clear = 2
            case vivid = 3
        }
    }

    func recordDream(content: String, quality: DreamEntry.DreamQuality, isLucid: Bool) -> DreamEntry {
        DreamEntry(
            id: UUID(),
            title: extractTitle(from: content),
            content: content,
            recordedAt: Date(),
            quality: quality,
            isLucid: isLucid,
            symbols: extractSymbols(from: content)
        )
    }

    private func extractTitle(from content: String) -> String {
        let firstLine = content.components(separatedBy: .newlines).first ?? "Dream"
        return String(firstLine.prefix(50))
    }

    private func extractSymbols(from content: String) -> [String] {
        // Simple keyword extraction
        let symbols = ["water", "fire", "animal", "person", "house", "car", "tree", "sky", "road"]
        return symbols.filter { content.lowercased().contains($0) }
    }

    // MARK: - Dream Visualization

    struct DreamVisualization: Identifiable {
        let id = UUID()
        let dreamId: UUID
        let imageData: Data
        let mood: Mood
        let createdAt: Date

        enum Mood: String {
            case peaceful, scary, happy, sad, mysterious
        }
    }

    func generateVisualization(for dream: DreamEntry, mood: DreamVisualization.Mood) async -> DreamVisualization? {
        // In real implementation, would use Stable Diffusion or similar
        // For now, return placeholder
        return nil
    }

    // MARK: - Community

    struct CommunityDream: Identifiable {
        let id = UUID()
        let dreamContent: String
        let authorAnonymous: Bool
        let symbolTags: [String]
        let lucidityLevel: Int
    }

    func shareAnonymously(dream: DreamEntry) -> CommunityDream {
        CommunityDream(
            dreamContent: dream.content,
            authorAnonymous: true,
            symbolTags: dream.symbols,
            lucidityLevel: dream.isLucid ? 3 : 1
        )
    }

    // MARK: - Lucid Dreaming Tools

    struct RealityCheck {
        let question: String
        let normalAnswer: String

        static let defaults: [RealityCheck] = [
            RealityCheck(question: "Am I dreaming?", normalAnswer: "No, this is real"),
            RealityCheck(question: "How did I get here?", normalAnswer: "I walked/drived"),
            RealityCheck(question: "Can I fly?", normalAnswer: "No"),
            RealityCheck(question: "What day is it?", normalAnswer: "Today is [weekday]")
        ]
    }
}
