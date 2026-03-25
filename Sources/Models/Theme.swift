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

    init(
        cloudSyncEnabled: Bool = false,
        morningPromptEnabled: Bool = true,
        morningPromptTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
        selectedTheme: AppTheme = .dark
    ) {
        self.cloudSyncEnabled = cloudSyncEnabled
        self.morningPromptEnabled = morningPromptEnabled
        self.morningPromptTime = morningPromptTime
        self.selectedTheme = selectedTheme
    }

    static let `default` = AppSettings()
}
