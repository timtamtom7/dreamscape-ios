import Foundation
import SwiftUI

/// R13: Retention tracking for Dreamscape
/// Day 1: first dream
/// Day 3: first interpretation
/// Day 7: first symbol insight
@MainActor
final class RetentionService: ObservableObject {
    static let shared = RetentionService()

    private let installDateKey = "dreamscape_install_date"
    private let day1DreamKey = "day1_dream_completed"
    private let day3InterpretationKey = "day3_interpretation_completed"
    private let day7SymbolKey = "day7_symbol_completed"
    private let lastActiveDateKey = "dreamscape_last_active"

    @Published var daysSinceInstall: Int = 0
    @Published var day1Completed: Bool = false
    @Published var day3Completed: Bool = false
    @Published var day7Completed: Bool = false

    var currentMilestone: RetentionMilestone {
        if day7Completed { return .completed }
        else if day3Completed { return .day7 }
        else if day1Completed { return .day3 }
        else { return .day1 }
    }

    enum RetentionMilestone: String {
        case day1 = "Record your first dream"
        case day3 = "Get your first AI interpretation"
        case day7 = "Discover your first symbol insight"
        case completed = "Dream journal active!"
    }

    init() {
        loadRetentionData()
    }

    func loadRetentionData() {
        if let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date {
            daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        } else {
            UserDefaults.standard.set(Date(), forKey: installDateKey)
            daysSinceInstall = 0
        }

        day1Completed = UserDefaults.standard.bool(forKey: day1DreamKey)
        day3Completed = UserDefaults.standard.bool(forKey: day3InterpretationKey)
        day7Completed = UserDefaults.standard.bool(forKey: day7SymbolKey)
        UserDefaults.standard.set(Date(), forKey: lastActiveDateKey)
    }

    func recordDreamRecorded() {
        guard !day1Completed else { return }
        day1Completed = true
        UserDefaults.standard.set(true, forKey: day1DreamKey)
        trackMilestone(.day1)
    }

    func recordInterpretationViewed() {
        guard !day3Completed else { return }
        day3Completed = true
        UserDefaults.standard.set(true, forKey: day3InterpretationKey)
        trackMilestone(.day3)
    }

    func recordSymbolDiscovered() {
        guard !day7Completed else { return }
        day7Completed = true
        UserDefaults.standard.set(true, forKey: day7SymbolKey)
        trackMilestone(.day7)
    }

    private func trackMilestone(_ milestone: RetentionMilestone) {
        print("[Retention] Milestone completed: \(milestone.rawValue)")
    }
}
