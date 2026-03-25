import Foundation
import Combine
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined

    private let settingsKey = "dreamscape_settings"
    private let cloudSyncService = CloudSyncService.shared
    private let databaseService = DatabaseService.shared

    init() {
        settings = SettingsViewModel.loadSettings()
        checkNotificationStatus()
    }

    private static func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "dreamscape_settings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }

        // Apply notification settings
        if settings.morningPromptEnabled {
            scheduleMorningNotification()
        } else {
            cancelMorningNotification()
        }

        // R3: WBTB notification
        if settings.wbtbEnabled {
            scheduleWBTBNotification()
        } else {
            cancelWBTBNotification()
        }
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let status = settings.authorizationStatus
            DispatchQueue.main.async {
                self?.notificationAuthorizationStatus = status
            }
        }
    }

    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                if granted {
                    settings.morningPromptEnabled = true
                    scheduleMorningNotification()
                }
            }
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    private func scheduleMorningNotification() {
        cancelMorningNotification()

        let content = UNMutableNotificationContent()
        content.title = "Dreamscape"
        content.body = "Good morning! Ready to record your dreams from last night?"
        content.sound = .default

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: settings.morningPromptTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "morning_dream_prompt",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    private func cancelMorningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["morning_dream_prompt"]
        )
    }

    // MARK: - WBTB Notifications (R3)

    private func scheduleWBTBNotification() {
        cancelWBTBNotification()

        let content = UNMutableNotificationContent()
        content.title = "Lucid Dream Time ⭐"
        content.body = "Time to wake up! Stay awake for \(settings.wbtbAwakeMinutes) minutes to trigger a lucid dream."
        content.sound = .default
        content.categoryIdentifier = "WBTB"

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: settings.wbtbReminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "wbtb_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule WBTB notification: \(error)")
            }
        }
    }

    private func cancelWBTBNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["wbtb_reminder"]
        )
    }

    func setMorningPromptTime(_ date: Date) {
        settings.morningPromptTime = date
    }

    func setCloudSyncEnabled(_ enabled: Bool) {
        settings.cloudSyncEnabled = enabled
    }

    func setTheme(_ theme: AppTheme) {
        settings.selectedTheme = theme
    }

    func triggerCloudSync() async {
        do {
            let dreams = try databaseService.fetchAllDreams()
            try await cloudSyncService.syncDreams(dreams)
        } catch {
            print("Cloud sync error: \(error)")
        }
    }
}
