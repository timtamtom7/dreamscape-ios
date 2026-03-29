import Foundation

// MARK: - SymbolService
/// Tracks recurring symbols across dreams and provides personalized insights.
final class SymbolService: @unchecked Sendable {
    nonisolated(unsafe) static let shared = SymbolService()

    private var symbolHistory: [String: SymbolHistory] = [:]

    init() {}

    // MARK: - Public API

    /// Record that a symbol appeared in a dream
    func recordSymbolAppearance(_ symbolName: String, in dream: Dream, category: DreamSymbol.Category) {
        let key = symbolName.lowercased()
        
        if var history = symbolHistory[key] {
            history.occurrences.append(SymbolOccurrence(dreamId: dream.id, date: dream.date))
            history.totalCount += 1
            history.lastSeen = dream.date
            history.category = category
            symbolHistory[key] = history
        } else {
            symbolHistory[key] = SymbolHistory(
                name: symbolName,
                category: category,
                totalCount: 1,
                lastSeen: dream.date,
                occurrences: [SymbolOccurrence(dreamId: dream.id, date: dream.date)]
            )
        }
    }

    /// Get all tracked symbol histories
    func getAllSymbolHistories() -> [SymbolHistory] {
        return Array(symbolHistory.values).sorted { $0.totalCount > $1.totalCount }
    }

    /// Get symbol history for a specific symbol
    func getSymbolHistory(for symbolName: String) -> SymbolHistory? {
        return symbolHistory[symbolName.lowercased()]
    }

    /// Get recurring symbols with frequency stats
    func getRecurringSymbols(minOccurrences: Int = 2) -> [SymbolHistory] {
        return symbolHistory.values
            .filter { $0.totalCount >= minOccurrences }
            .sorted { $0.totalCount > $1.totalCount }
    }

    /// Get symbol frequency for a time period
    func getSymbolFrequency(for symbolName: String, in dreams: [Dream], period: TimePeriod = .month) -> SymbolFrequency {
        let key = symbolName.lowercased()
        let cutoffDate = period.cutoffDate
        
        let relevantDreams = dreams.filter { dream in
            dream.date >= cutoffDate && dream.narrative.lowercased().contains(key)
        }

        let occurrencesByWeek = Dictionary(grouping: relevantDreams) { dream -> Int in
            let weekOfYear = Calendar.current.component(.weekOfYear, from: dream.date)
            let year = Calendar.current.component(.year, from: dream.date)
            return year * 100 + weekOfYear
        }

        return SymbolFrequency(
            symbolName: symbolName,
            totalOccurrences: relevantDreams.count,
            occurrencesByWeek: occurrencesByWeek.mapValues { $0.count },
            period: period,
            dreams: relevantDreams
        )
    }

    /// Get month-over-month symbol stats
    func getMonthlySymbolStats(for symbolName: String, in dreams: [Dream]) -> MonthlyStats {
        let key = symbolName.lowercased()
        let calendar = Calendar.current
        
        let now = Date()
        let thisMonth = dreams.filter { dream in
            let components = calendar.dateComponents([.year, .month], from: dream.date)
            let currentComponents = calendar.dateComponents([.year, .month], from: now)
            return components.year == currentComponents.year &&
                   components.month == currentComponents.month &&
                   dream.narrative.lowercased().contains(key)
        }

        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let lastMonth = dreams.filter { dream in
            let components = calendar.dateComponents([.year, .month], from: dream.date)
            let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastMonthDate)
            return components.year == lastMonthComponents.year &&
                   components.month == lastMonthComponents.month &&
                   dream.narrative.lowercased().contains(key)
        }

        let percentChange: Double? = lastMonth.isEmpty ? nil : 
            Double(thisMonth.count - lastMonth.count) / Double(lastMonth.count) * 100

        return MonthlyStats(
            symbolName: symbolName,
            thisMonthCount: thisMonth.count,
            lastMonthCount: lastMonth.count,
            percentChange: percentChange
        )
    }

    /// Generate a personalized message about symbol frequency
    func generateFrequencyMessage(for symbolName: String, in dreams: [Dream]) -> String {
        let key = symbolName.lowercased()
        let stats = getMonthlySymbolStats(for: symbolName, in: dreams)

        if stats.thisMonthCount == 0 && stats.lastMonthCount == 0 {
            return "This symbol hasn't appeared in your recorded dreams yet."
        }

        var message = "You've dreamed of \(symbolName.lowercased()) "
        
        if stats.thisMonthCount > 0 {
            message += "\(stats.thisMonthCount) time\(stats.thisMonthCount == 1 ? "" : "s") this month."
        } else if stats.lastMonthCount > 0 {
            message += "\(stats.lastMonthCount) time\(stats.lastMonthCount == 1 ? "" : "s") last month."
        }

        // Add interpretation context
        let interpretation = AIDreamService.shared.interpretSymbol(symbolName, inContextOf: dreams)
        message += " \(interpretation)"

        return message
    }

    /// Get symbol relationships (symbols that appear together)
    func getSymbolRelationships(for symbolName: String, in dreams: [Dream]) -> [String] {
        let key = symbolName.lowercased()
        
        var relatedSymbols: Set<String> = []
        
        for dream in dreams {
            if dream.narrative.lowercased().contains(key) {
                for detectedSymbol in dream.detectedSymbols {
                    let otherKey = detectedSymbol.lowercased()
                    if otherKey != key {
                        relatedSymbols.insert(detectedSymbol.capitalized)
                    }
                }
            }
        }

        return Array(relatedSymbols).sorted()
    }

    /// Track symbol evolution over time
    func getSymbolEvolution(for symbolName: String, in dreams: [Dream]) -> [SymbolEvolutionPoint] {
        let key = symbolName.lowercased()
        let calendar = Calendar.current
        
        let relevantDreams = dreams
            .filter { $0.narrative.lowercased().contains(key) }
            .sorted { $0.date < $1.date }

        var evolutionPoints: [SymbolEvolutionPoint] = []
        var runningCount = 0

        for dream in relevantDreams {
            runningCount += 1
            evolutionPoints.append(SymbolEvolutionPoint(
                date: dream.date,
                dreamId: dream.id,
                occurrenceNumber: runningCount,
                context: extractSymbolContext(dream.narrative, symbol: key)
            ))
        }

        return evolutionPoints
    }

    /// Get category distribution across all dreams
    func getCategoryDistribution(in dreams: [Dream]) -> [DreamSymbol.Category: Int] {
        var distribution: [DreamSymbol.Category: Int] = [:]

        for dream in dreams {
            for symbolName in dream.detectedSymbols {
                let category = categorizeSymbol(symbolName)
                distribution[category, default: 0] += 1
            }
        }

        return distribution
    }

    // MARK: - Private Helpers

    private func categorizeSymbol(_ name: String) -> DreamSymbol.Category {
        let lowercased = name.lowercased()
        
        let emotionKeywords = ["fear", "joy", "sad", "happy", "angry", "peace", "love", "hate", "anxious", "calm", "freedom"]
        let elementKeywords = ["water", "fire", "earth", "air", "wind", "storm", "rain", "snow", "ocean", "river", "moon", "sun", "stars", "sky"]
        let placeKeywords = ["house", "home", "city", "forest", "beach", "mountain", "room", "building", "garden", "library", "school"]
        let animalKeywords = ["dog", "cat", "bird", "snake", "horse", "wolf", "fish", "butterfly", "monkey", "animal"]

        if emotionKeywords.contains(where: { lowercased.contains($0) }) {
            return .emotion
        } else if elementKeywords.contains(where: { lowercased.contains($0) }) {
            return .element
        } else if placeKeywords.contains(where: { lowercased.contains($0) }) {
            return .place
        } else if animalKeywords.contains(where: { lowercased.contains($0) }) {
            return .animal
        } else {
            return .object
        }
    }

    private func extractSymbolContext(_ narrative: String, symbol: String) -> String {
        let words = narrative.lowercased().split(separator: " ")
        guard let index = words.firstIndex(where: { $0.contains(symbol) }) else {
            return ""
        }

        let startIndex = max(0, Int(index) - 2)
        let endIndex = min(words.count, Int(index) + 3)
        let contextWords = words[startIndex..<endIndex]

        return contextWords.joined(separator: " ")
    }
}

// MARK: - Supporting Types

/// Historical tracking data for a symbol
struct SymbolHistory: Identifiable, Equatable {
    var id: String { name }
    let name: String
    var category: DreamSymbol.Category
    var totalCount: Int
    var lastSeen: Date?
    var occurrences: [SymbolOccurrence]

    var formattedFrequency: String {
        if totalCount == 1 {
            return "1 time"
        } else {
            return "\(totalCount) times"
        }
    }

    var lastSeenDescription: String {
        guard let lastSeen = lastSeen else { return "Never" }
        let daysSince = Calendar.current.dateComponents([.day], from: lastSeen, to: Date()).day ?? 0
        
        if daysSince == 0 {
            return "Today"
        } else if daysSince == 1 {
            return "Yesterday"
        } else if daysSince < 7 {
            return "\(daysSince) days ago"
        } else if daysSince < 30 {
            let weeks = daysSince / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else {
            let months = daysSince / 30
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }
    }
}

/// Single occurrence of a symbol in a dream
struct SymbolOccurrence: Codable, Equatable {
    let dreamId: UUID
    let date: Date
}

/// Time period for filtering
enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case allTime = "All Time"

    var id: String { rawValue }

    var cutoffDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .quarter:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return Date.distantPast
        }
    }
}

/// Frequency data for a symbol over time
struct SymbolFrequency: Equatable {
    let symbolName: String
    let totalOccurrences: Int
    let occurrencesByWeek: [Int: Int]  // year*100 + weekOfYear -> count
    let period: TimePeriod
    let dreams: [Dream]

    var peakWeek: (week: Int, count: Int)? {
        occurrencesByWeek.max { $0.value < $1.value }.map { (Int(String($0.key).suffix(2)) ?? 0, $0.value) }
    }

    var averagePerWeek: Double {
        guard !occurrencesByWeek.isEmpty else { return 0 }
        let totalWeeks = occurrencesByWeek.count
        return Double(totalOccurrences) / Double(max(1, totalWeeks))
    }
}

/// Monthly statistics for a symbol
struct MonthlyStats: Equatable {
    let symbolName: String
    let thisMonthCount: Int
    let lastMonthCount: Int
    let percentChange: Double?

    var changeDescription: String {
        guard let change = percentChange else {
            return "No previous data"
        }
        
        let direction = change >= 0 ? "↑" : "↓"
        return "\(direction) \(abs(Int(change)))% from last month"
    }
}

/// Evolution point for symbol tracking
struct SymbolEvolutionPoint: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let dreamId: UUID
    let occurrenceNumber: Int
    let context: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Lucidity Tracking

extension SymbolService {
    /// Calculate overall lucidity improvement
    func calculateLucidityImprovement(in dreams: [Dream]) -> LucidityProgress {
        let sortedDreams = dreams.sorted { $0.date < $1.date }
        
        guard sortedDreams.count >= 4 else {
            return LucidityProgress(
                baselineLevel: dreams.first?.lucidityLevel ?? 1,
                currentLevel: dreams.last?.lucidityLevel ?? 1,
                improvementPercent: 0,
                sessionCount: dreams.count,
                trend: .stable
            )
        }

        // First 3 dreams as baseline
        let baselineAvg = sortedDreams.prefix(3).map { $0.lucidityLevel }.reduce(0, +) / 3
        
        // Last 3 dreams as current
        let currentAvg = sortedDreams.suffix(3).map { $0.lucidityLevel }.reduce(0, +) / 3

        let improvement = baselineAvg > 0 ? 
            Double(currentAvg - baselineAvg) / Double(baselineAvg) * 100 : 0

        let trend: LucidityTrend
        if improvement > 20 {
            trend = .improving
        } else if improvement < -20 {
            trend = .declining
        } else {
            trend = .stable
        }

        return LucidityProgress(
            baselineLevel: baselineAvg,
            currentLevel: currentAvg,
            improvementPercent: improvement,
            sessionCount: dreams.count,
            trend: trend
        )
    }

    /// Get lucidity milestone achievements
    func getLucidityMilestones(in dreams: [Dream]) -> [LucidityMilestone] {
        let lucidDreams = dreams.filter { $0.lucidityLevel >= 4 }
        
        var milestones: [LucidityMilestone] = []
        
        // First lucid dream
        if let firstLucid = lucidDreams.first {
            milestones.append(LucidityMilestone(
                title: "First Lucid Dream",
                description: "Your journey into conscious dreaming began",
                achievedDate: firstLucid.date,
                type: .firstLucid
            ))
        }

        // Count milestones
        if lucidDreams.count >= 10 {
            milestones.append(LucidityMilestone(
                title: "Lucid Explorer",
                description: "Experienced 10+ lucid dreams",
                achievedDate: lucidDreams[9].date,
                type: .countMilestone
            ))
        }

        if lucidDreams.count >= 50 {
            milestones.append(LucidityMilestone(
                title: "Lucid Master",
                description: "50 lucid dreams recorded",
                achievedDate: lucidDreams[49].date,
                type: .countMilestone
            ))
        }

        // High lucidity milestone
        if let maxLucid = dreams.max(by: { $0.lucidityLevel < $1.lucidityLevel }),
           maxLucid.lucidityLevel == 5 {
            milestones.append(LucidityMilestone(
                title: "Full Lucidity",
                description: "Achieved maximum lucidity level",
                achievedDate: maxLucid.date,
                type: .maxLucidity
            ))
        }

        return milestones
    }
}

/// Lucidity progress tracking
struct LucidityProgress: Equatable {
    let baselineLevel: Int
    let currentLevel: Int
    let improvementPercent: Double
    let sessionCount: Int
    let trend: LucidityTrend

    var summary: String {
        if improvementPercent > 0 {
            return "Your lucidity has increased \(Int(improvementPercent))% since you started journaling."
        } else if improvementPercent < 0 {
            return "Lucidity levels are currently lower. Keep practicing dream recall!"
        } else {
            return "Lucidity is stable. Keep recording your dreams!"
        }
    }
}

/// Lucidity trend direction
enum LucidityTrend: String {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
}

/// Achievement milestone
struct LucidityMilestone: Identifiable, Equatable {
    var id: String { title }
    let title: String
    let description: String
    let achievedDate: Date
    let type: MilestoneType

    enum MilestoneType {
        case firstLucid
        case countMilestone
        case maxLucidity
        case streak
    }
}
