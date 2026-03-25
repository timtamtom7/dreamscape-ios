import Foundation
import ActivityKit

/// Shared Activity Attributes for Dream Streak Live Activity.
/// Included in both the main app and widget extension targets.
struct DreamStreakAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentStreak: Int
        var longestStreak: Int
        var lastDreamDate: Date?
        var motivationalMessage: String
    }

    var dreamerName: String
}
