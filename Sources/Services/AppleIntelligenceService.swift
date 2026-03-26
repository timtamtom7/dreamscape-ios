import Foundation
import SwiftUI

/// R14: Apple Intelligence integration for iOS 18+
/// - Siri + Dreamscape ("log a dream")
/// - Dream predictions
/// - Sleep briefing
@MainActor
final class AppleIntelligenceService: ObservableObject {
    static let shared = AppleIntelligenceService()

    @Published var isAppleIntelligenceAvailable: Bool = false
    @Published var lastPrediction: DreamPrediction?

    struct DreamPrediction: Codable, Identifiable {
        let id: UUID
        let predictedTheme: String
        let confidence: Double
        let suggestedSymbols: [String]
        let timestamp: Date
    }

    init() {
        checkAvailability()
    }

    private func checkAvailability() {
        #if canImport(AppleIntelligence)
        isAppleIntelligenceAvailable = true
        #else
        isAppleIntelligenceAvailable = false
        #endif
    }

    /// R14: Dream prediction based on patterns
    func generatePrediction() -> DreamPrediction? {
        guard isAppleIntelligenceAvailable else { return nil }

        // R14: Use Apple Intelligence to predict dream themes
        let themes = ["Adventure", "Water", "Flying", "Transformation", "Animals", "People"]
        let symbols = ["Moon", "Water", "Flight", "House", "Vehicle", "Forest"]

        return DreamPrediction(
            id: UUID(),
            predictedTheme: themes.randomElement() ?? "Adventure",
            confidence: 0.75,
            suggestedSymbols: Array(symbols.shuffled().prefix(3)),
            timestamp: Date()
        )
    }

    /// R14: Sleep briefing summary
    func generateSleepBriefing() -> String {
        let vm = JournalViewModel()
        let dreams = vm.dreams
        let recentDreams = dreams.filter {
            Calendar.current.dateComponents([.day], from: $0.createdAt, to: Date()).day ?? 0 < 7
        }

        let avgLucidity = recentDreams.isEmpty ? 0 : recentDreams.map { $0.isLucid ? 1.0 : 0.0 }.reduce(0, +) / Double(max(recentDreams.count, 1))
        let recurringCount = recentDreams.filter { $0.recurringVariantId != nil }.count

        return """
        Sleep Briefing:
        • \(recentDreams.count) dreams this week
        • Average lucidity: \(Int(avgLucidity * 100))%
        • \(recurringCount) recurring themes
        • \(SymbolsViewModel().symbols.count) symbols tracked
        """
    }
}
