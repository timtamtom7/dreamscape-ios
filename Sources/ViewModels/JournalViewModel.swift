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

    func saveDream(content: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Analyze the dream content
            let analysisResult = await analysisService.analyzeDream(content)

            let newDream = Dream(
                content: content,
                summary: analysisResult.summary,
                symbols: analysisResult.symbols,
                createdAt: Date(),
                updatedAt: Date()
            )

            try databaseService.saveDream(newDream)
            dreams.insert(newDream, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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
