import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Design Tokens

enum DesignTokens {
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let capsule: CGFloat = 9999
    }

    // MARK: - Touch Targets (iOS HIG minimum: 44pt)
    enum TouchTarget {
        static let minimum: CGFloat = 44
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Animation
    enum Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.3
        static let slow: Double = 0.5
    }
}

// MARK: - Haptic Feedback

#if canImport(UIKit)
enum HapticFeedback {
    /// Light impact - subtle feedback for micro-interactions
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact - standard feedback for button presses
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact - significant feedback for important actions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Selection changed - for picker/segment changes
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Success notification
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
#else
enum HapticFeedback {
    static func light() {}
    static func medium() {}
    static func heavy() {}
    static func selection() {}
    static func success() {}
    static func warning() {}
    static func error() {}
}
#endif

// MARK: - App Theme

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
