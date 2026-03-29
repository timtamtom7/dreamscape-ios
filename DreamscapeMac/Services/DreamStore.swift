import Foundation
import SwiftUI
import Combine

@Observable
class DreamStore {
    var dreams: [Dream] = Dream.samples
    var symbols: [DreamSymbol] = DreamSymbol.samples

    var streak: Int {
        calculateStreak()
    }

    var lucidDreamCount: Int {
        dreams.filter { $0.lucidityLevel >= 4 }.count
    }

    var mostCommonMood: Dream.Mood {
        let moodCounts = Dictionary(grouping: dreams, by: { $0.mood })
        return moodCounts.max(by: { $0.value.count < $1.value.count })?.key ?? .neutral
    }

    var dreamsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return dreams.filter { $0.date >= weekAgo }.count
    }

    func addDream(_ dream: Dream) {
        dreams.insert(dream, at: 0)
    }

    func updateDream(_ dream: Dream) {
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index] = dream
        }
    }

    func deleteDream(_ dream: Dream) {
        dreams.removeAll { $0.id == dream.id }
    }

    func analyzeDream(_ dream: Dream) -> Dream {
        // Simulate AI analysis
        let detectedSymbols = extractSymbols(from: dream.narrative)
        let summary = generateSummary(for: dream)

        return Dream(
            id: dream.id,
            title: dream.title,
            narrative: dream.narrative,
            date: dream.date,
            mood: dream.mood,
            lucidityLevel: dream.lucidityLevel,
            tags: dream.tags,
            summary: summary,
            detectedSymbols: detectedSymbols,
            isAnalyzed: true
        )
    }

    private func extractSymbols(from narrative: String) -> [String] {
        // Simple keyword extraction - in production would use NLP
        let keywords = ["ocean", "moon", "stars", "flight", "water", "forest", "house", "city", "books", "bird", "mountain", "river", "sky", "cloud", "wind"]
        let words = narrative.lowercased().split(separator: " ")
        return keywords.filter { keyword in
            words.contains { $0.contains(keyword) }
        }
    }

    private func generateSummary(for dream: Dream) -> String {
        let summaries = [
            "A vivid \(dream.mood.rawValue.lowercased()) dream exploring themes of self-discovery and inner landscape.",
            "This dream reflects your subconscious processing emotions through symbolic imagery.",
            "A memorable dream with lucidity level \(dream.lucidityLevel)/5, suggesting strong self-awareness.",
            "Dream symbols point to a period of transformation and personal growth."
        ]
        return summaries.randomElement() ?? summaries[0]
    }

    private func calculateStreak() -> Int {
        guard !dreams.isEmpty else { return 0 }
        let sortedDreams = dreams.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())

        for dream in sortedDreams {
            let dreamDate = Calendar.current.startOfDay(for: dream.date)
            let daysDiff = Calendar.current.dateComponents([.day], from: dreamDate, to: currentDate).day ?? 0

            if daysDiff == 0 || daysDiff == 1 {
                if daysDiff == 0 || streak == 0 {
                    streak += 1
                    currentDate = dreamDate
                }
            } else {
                break
            }
        }
        return streak
    }

    func dreamsByMood(_ mood: Dream.Mood) -> [Dream] {
        dreams.filter { $0.mood == mood }
    }

    func dreamsByDate(_ date: Date) -> [Dream] {
        let calendar = Calendar.current
        return dreams.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func searchDreams(_ query: String) -> [Dream] {
        guard !query.isEmpty else { return dreams }
        let lowercased = query.lowercased()
        return dreams.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.narrative.lowercased().contains(lowercased) ||
            $0.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }

    func topSymbols(limit: Int = 5) -> [DreamSymbol] {
        symbols.sorted { $0.occurrenceCount > $1.occurrenceCount }.prefix(limit).map { $0 }
    }
}
