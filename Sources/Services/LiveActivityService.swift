import Foundation
import ActivityKit

/// Manages Dream Streak Live Activity on the Lock Screen and Dynamic Island.
/// Part of R5: iOS 26 Live Activities & Dynamic Island support.
@MainActor
final class LiveActivityService: ObservableObject {
    static let shared = LiveActivityService()

    @Published private(set) var currentActivityId: String?
    @Published private(set) var isActivityActive = false

    private var activityToken: Task<Void, Never>?

    private init() {}

    // MARK: - Start Live Activity

    nonisolated func startDreamStreakActivity(
        currentStreak: Int,
        longestStreak: Int,
        lastDreamDate: Date?,
        motivationalMessage: String
    ) {
        Task { @MainActor in
            await self._startDreamStreakActivity(
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastDreamDate: lastDreamDate,
                motivationalMessage: motivationalMessage
            )
        }
    }

    private func _startDreamStreakActivity(
        currentStreak: Int,
        longestStreak: Int,
        lastDreamDate: Date?,
        motivationalMessage: String
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        // End any existing activity first
        await _endDreamStreakActivity()

        let attributes = DreamStreakAttributes(dreamerName: "Dreamer")
        let contentState = DreamStreakAttributes.ContentState(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastDreamDate: lastDreamDate,
            motivationalMessage: motivationalMessage
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivityId = activity.id
            isActivityActive = true
            print("Started Dream Streak Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    // MARK: - Update Live Activity

    nonisolated func updateDreamStreakActivity(
        currentStreak: Int,
        longestStreak: Int,
        lastDreamDate: Date?,
        motivationalMessage: String
    ) {
        Task { @MainActor in
            await self._updateDreamStreakActivity(
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastDreamDate: lastDreamDate,
                motivationalMessage: motivationalMessage
            )
        }
    }

    private func _updateDreamStreakActivity(
        currentStreak: Int,
        longestStreak: Int,
        lastDreamDate: Date?,
        motivationalMessage: String
    ) async {
        guard let activityId = currentActivityId else {
            // No active activity — start one
            await _startDreamStreakActivity(
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastDreamDate: lastDreamDate,
                motivationalMessage: motivationalMessage
            )
            return
        }

        let contentState = DreamStreakAttributes.ContentState(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastDreamDate: lastDreamDate,
            motivationalMessage: motivationalMessage
        )

        // Find the activity by ID and update
        let activities = Activity<DreamStreakAttributes>.activities
        guard let activity = activities.first(where: { $0.id == activityId }) else {
            // Activity ended externally — start fresh
            await _startDreamStreakActivity(
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastDreamDate: lastDreamDate,
                motivationalMessage: motivationalMessage
            )
            return
        }

        // Capture activity.id (Sendable String) and look up activity in detached context
        let targetId = activity.id
        Task.detached {
            let allActivities = Activity<DreamStreakAttributes>.activities
            if let found = allActivities.first(where: { $0.id == targetId }) {
                await found.update(ActivityContent(state: contentState, staleDate: nil))
            }
        }
    }

    // MARK: - End Live Activity

    nonisolated func endDreamStreakActivity() {
        Task { @MainActor in
            await self._endDreamStreakActivity()
        }
    }

    private func _endDreamStreakActivity() async {
        guard let activityId = currentActivityId else { return }

        let activities = Activity<DreamStreakAttributes>.activities
        guard activities.contains(where: { $0.id == activityId }) else {
            currentActivityId = nil
            isActivityActive = false
            return
        }

        let finalState = DreamStreakAttributes.ContentState(
            currentStreak: 0,
            longestStreak: 0,
            lastDreamDate: nil,
            motivationalMessage: "Sweet dreams!"
        )

        // Use detached task to avoid Activity sendability issues
        let targetId = activityId
        Task.detached {
            let allActivities = Activity<DreamStreakAttributes>.activities
            if let found = allActivities.first(where: { $0.id == targetId }) {
                await found.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
        }

        currentActivityId = nil
        isActivityActive = false
    }

    // MARK: - Motivational Messages

    nonisolated func motivationalMessage(for streak: Int) -> String {
        switch streak {
        case 1...3:
            return "Great start! Keep the dream journal going!"
        case 4...7:
            return "You're building a powerful dream habit!"
        case 8...14:
            return "A week of dream recall! Your subconscious is opening up."
        case 15...30:
            return "Amazing consistency! Patterns are emerging."
        case 31...60:
            return "A month of dream awareness — you're becoming lucid!"
        case 61...:
            return "Master dreamer status. Your inner world is rich and deep."
        default:
            return "Start your dream streak today!"
        }
    }

    // MARK: - Streak Calculation

    func calculateAndUpdateStreak() async {
        let databaseService = DatabaseService.shared
        let dreams = (try? databaseService.fetchAllDreams()) ?? []
        let calendar = Calendar.current

        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var checkDate = Date()

        // Count current streak (consecutive days with dreams)
        for _ in 0..<90 {
            let hadDream = dreams.contains { dream in
                calendar.isDate(dream.createdAt, inSameDayAs: checkDate)
            }

            if hadDream {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        // Calculate longest streak
        let sortedDates = dreams.map { calendar.startOfDay(for: $0.createdAt) }.sorted()
        var previousDate: Date?

        for date in sortedDates {
            if let prev = previousDate {
                let dayDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if dayDiff == 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDate = date
        }
        longestStreak = max(longestStreak, tempStreak)

        let lastDream = dreams.first
        let message = motivationalMessage(for: currentStreak)

        await _updateDreamStreakActivity(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastDreamDate: lastDream?.createdAt,
            motivationalMessage: message
        )
    }
}
