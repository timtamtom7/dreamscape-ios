import Foundation
import Combine

/// R3: ViewModel for the Dream Gallery
@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var galleryItems: [GalleryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let databaseService = DatabaseService.shared
    private let sleepDataService = SleepDataService.shared

    var totalSymbols: Int {
        galleryItems.reduce(0) { $0 + $1.dream.symbols.count }
    }

    var correlationScore: String {
        let scores = galleryItems.compactMap { item -> Int? in
            guard let sleep = try? sleepDataService.fetchSleepRecord(for: item.dream.createdAt) else { return nil }
            return sleep.quality.score
        }
        
        guard !scores.isEmpty else { return "No Data" }
        
        let total = scores.reduce(0, +)
        let avgScore = Double(total) / Double(scores.count)

        if avgScore >= 4.5 { return "Excellent" }
        else if avgScore >= 3.5 { return "Good" }
        else if avgScore >= 2.5 { return "Fair" }
        else { return "Poor" }
    }

    func loadGallery() {
        isLoading = true
        errorMessage = nil

        do {
            let dreams = try databaseService.fetchAllDreams()
            let arts = try sleepDataService.fetchAllDreamArts()

            galleryItems = dreams.map { dream in
                let art = arts.first { $0.dreamId == dream.id }
                return GalleryItem(dream: dream, art: art)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
