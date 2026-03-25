import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        }
    }
}

struct AppSettings: Codable {
    var cloudSyncEnabled: Bool
    var morningPromptEnabled: Bool
    var morningPromptTime: Date
    var selectedTheme: AppTheme

    // R3: WBTB Reminder settings
    var wbtbEnabled: Bool
    var wbtbHoursAfterSleep: Int // hours after falling asleep to wake up
    var wbtbAwakeMinutes: Int // minutes to stay awake
    var wbtbReminderTime: Date // specific time to set alarm

    init(
        cloudSyncEnabled: Bool = false,
        morningPromptEnabled: Bool = true,
        morningPromptTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
        selectedTheme: AppTheme = .dark,
        wbtbEnabled: Bool = false,
        wbtbHoursAfterSleep: Int = 5,
        wbtbAwakeMinutes: Int = 30,
        wbtbReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 4, minute: 30)) ?? Date()
    ) {
        self.cloudSyncEnabled = cloudSyncEnabled
        self.morningPromptEnabled = morningPromptEnabled
        self.morningPromptTime = morningPromptTime
        self.selectedTheme = selectedTheme
        self.wbtbEnabled = wbtbEnabled
        self.wbtbHoursAfterSleep = wbtbHoursAfterSleep
        self.wbtbAwakeMinutes = wbtbAwakeMinutes
        self.wbtbReminderTime = wbtbReminderTime
    }

    static let `default` = AppSettings()
}
