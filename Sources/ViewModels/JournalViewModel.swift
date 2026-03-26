import Foundation
import Combine

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var dreams: [Dream] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingEntrySheet = false
    @Published var selectedDream: Dream?

    private let databaseService = DatabaseService.shared
    private let analysisService = DreamAnalysisService.shared

    init() {
        loadDreams()
    }

    func loadDreams() {
        isLoading = true
        errorMessage = nil

        do {
            dreams = try databaseService.fetchAllDreams()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveDream(content: String, mood: MoodTag? = nil, isLucid: Bool = false, photoData: Data? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            // Analyze the dream content
            let analysisResult = await analysisService.analyzeDream(content)

            // Handle photo attachment
            var photoURL: URL?
            if let data = photoData {
                let filename = UUID().uuidString + ".jpg"
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
                let photosDir = documentsURL.appendingPathComponent("dream_photos", isDirectory: true)

                // Create directory if needed
                try? FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)

                let fileURL = photosDir.appendingPathComponent(filename)
                try data.write(to: fileURL)
                photoURL = fileURL
            }

            // Detect recurring dreams
            let recurringVariantId = detectRecurringDream(content: content)

            let newDream = Dream(
                content: content,
                summary: analysisResult.summary,
                symbols: analysisResult.symbols,
                createdAt: Date(),
                updatedAt: Date(),
                mood: mood,
                isLucid: isLucid,
                recurringVariantId: recurringVariantId,
                attachedPhotoURL: photoURL,
                emotionalTags: analysisResult.emotionalTags
            )

            try databaseService.saveDream(newDream)
            dreams.insert(newDream, at: 0)

            // R5: Update Live Activity with new streak
            await LiveActivityService.shared.calculateAndUpdateStreak()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Detect if this dream is a variation of a recurring one
    private func detectRecurringDream(content: String) -> UUID? {
        let lowercased = content.lowercased()
        let words = Set(lowercased.components(separatedBy: .whitespacesAndNewlines).filter { $0.count > 3 })

        // Check for similarity with existing dreams
        for dream in dreams {
            let dreamWords = Set(dream.content.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { $0.count > 3 })
            let intersection = words.intersection(dreamWords)
            let similarity = Double(intersection.count) / Double(max(words.count, dreamWords.count))

            if similarity > 0.4 && dream.recurringVariantId != nil {
                return dream.recurringVariantId
            } else if similarity > 0.4 {
                return dream.id
            }
        }
        return nil
    }

    func deleteDream(_ dream: Dream) {
        do {
            try databaseService.deleteDream(id: dream.id)
            dreams.removeAll { $0.id == dream.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshDreams() async {
        loadDreams()
    }
}
