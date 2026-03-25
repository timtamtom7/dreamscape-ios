import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget Bundle

@main
struct DreamscapeWidgets: WidgetBundle {
    var body: some Widget {
        DreamStreakLiveActivity()
        DreamRecallWidget()
    }
}

// MARK: - Shared Theme Colors (duplicated from main app for widget access)

enum WidgetColors {
    static let backgroundPrimary = Color(red: 0.039, green: 0.039, blue: 0.078)
    static let surface = Color(red: 0.102, green: 0.094, blue: 0.188)
    static let auroraCyan = Color(red: 0.369, green: 0.918, blue: 0.831)
    static let nebulaPink = Color(red: 0.753, green: 0.518, blue: 0.988)
    static let starGold = Color(red: 0.988, green: 0.827, blue: 0.302)
    static let textPrimary = Color(red: 0.941, green: 0.941, blue: 1.0)
    static let textSecondary = Color(red: 0.545, green: 0.545, blue: 0.655)
}

// MARK: - Dream Streak Live Activity

struct DreamStreakLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DreamStreakAttributes.self) { context in
            // Lock screen / banner presentation
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(WidgetColors.starGold)
                        Text("\(context.state.currentStreak)")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(WidgetColors.auroraCyan)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Longest")
                            .font(.caption2)
                            .foregroundColor(WidgetColors.textSecondary)
                        Text("\(context.state.longestStreak)")
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(WidgetColors.starGold)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.state.motivationalMessage)
                            .font(.caption)
                            .foregroundColor(WidgetColors.textPrimary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { day in
                            Circle()
                                .fill(day < context.state.currentStreak ? WidgetColors.auroraCyan : WidgetColors.surface)
                                .frame(width: 10, height: 10)
                        }
                        Text("days")
                            .font(.caption2)
                            .foregroundColor(WidgetColors.textSecondary)
                    }
                }
            } compactLeading: {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(WidgetColors.starGold)
                        .font(.caption2)
                    Text("\(context.state.currentStreak)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(WidgetColors.auroraCyan)
                }
            } compactTrailing: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(WidgetColors.nebulaPink)
                    .font(.caption2)
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundColor(WidgetColors.starGold)
            }
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<DreamStreakAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Streak display
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(WidgetColors.starGold)
                    Text("\(context.state.currentStreak) day streak")
                        .font(.headline)
                        .foregroundColor(WidgetColors.textPrimary)
                }

                Text(context.state.motivationalMessage)
                    .font(.caption)
                    .foregroundColor(WidgetColors.textSecondary)
                    .lineLimit(1)

                // Week visualization
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { day in
                        Circle()
                            .fill(day < context.state.currentStreak ? WidgetColors.auroraCyan : WidgetColors.surface)
                            .frame(width: 10, height: 10)
                    }
                }
            }

            Spacer()

            // Longest streak
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(context.state.longestStreak)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(WidgetColors.starGold)
                Text("Longest")
                    .font(.caption2)
                    .foregroundColor(WidgetColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.102, green: 0.094, blue: 0.188))
        )
    }
}

// MARK: - Dream Recall Interactive Widget

struct DreamRecallEntry: TimelineEntry {
    let date: Date
    let lastDreamSnippet: String?
    let lastDreamDate: Date?
    let streak: Int
    let configuration: DreamRecallIntent
}

struct DreamRecallIntent: WidgetConfigurationIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Dream Recall"
    nonisolated(unsafe) static var description = IntentDescription("Track your dream journaling streak")

    @Parameter(title: "Show Last Dream", default: true)
    var showLastDream: Bool
}

struct DreamRecallProvider: AppIntentTimelineProvider {
    typealias Entry = DreamRecallEntry
    typealias Intent = DreamRecallIntent

    func placeholder(in context: Context) -> DreamRecallEntry {
        DreamRecallEntry(
            date: Date(),
            lastDreamSnippet: "I was flying over a golden city...",
            lastDreamDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            streak: 7,
            configuration: DreamRecallIntent()
        )
    }

    func snapshot(for configuration: DreamRecallIntent, in context: Context) async -> DreamRecallEntry {
        await fetchEntry(configuration: configuration)
    }

    func timeline(for configuration: DreamRecallIntent, in context: Context) async -> Timeline<DreamRecallEntry> {
        let entry = await fetchEntry(configuration: configuration)
        // Refresh every 4 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchEntry(configuration: DreamRecallIntent) async -> DreamRecallEntry {
        // In a real implementation, this would read from shared UserDefaults/App Group
        // For now, use placeholder data
        let snippet = configuration.showLastDream ? "Tap to record your dream..." : nil
        return DreamRecallEntry(
            date: Date(),
            lastDreamSnippet: snippet,
            lastDreamDate: nil,
            streak: 0,
            configuration: configuration
        )
    }
}

struct DreamRecallWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "DreamRecallWidget",
            intent: DreamRecallIntent.self,
            provider: DreamRecallProvider()
        ) { entry in
            DreamRecallWidgetView(entry: entry)
                .containerBackground(WidgetColors.backgroundPrimary, for: .widget)
        }
        .configurationDisplayName("Dream Recall")
        .description("Quick access to log your dreams and track your streak")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct DreamRecallWidgetView: View {
    var entry: DreamRecallEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryCircular:
            accessoryCircular
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(WidgetColors.nebulaPink)
                Text("Dreamscape")
                    .font(.caption2)
                    .foregroundColor(WidgetColors.textSecondary)
                Spacer()
                if entry.streak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(WidgetColors.starGold)
                        Text("\(entry.streak)")
                            .font(.caption2)
                            .foregroundColor(WidgetColors.starGold)
                    }
                }
            }

            Spacer()

            if let snippet = entry.lastDreamSnippet {
                Text(snippet)
                    .font(.caption)
                    .foregroundColor(WidgetColors.textPrimary)
                    .lineLimit(3)
            } else {
                Text("What did you dream?")
                    .font(.headline)
                    .foregroundColor(WidgetColors.textPrimary)
            }

            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(WidgetColors.auroraCyan)
                Text("Log Dream")
                    .font(.caption)
                    .foregroundColor(WidgetColors.auroraCyan)
            }
        }
        .padding(12)
    }

    private var mediumWidget: some View {
        HStack(spacing: 12) {
            // Left: prompt
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(WidgetColors.nebulaPink)
                    Text("Dream Recall")
                        .font(.caption)
                        .foregroundColor(WidgetColors.textSecondary)
                }

                Spacer()

                Text(entry.lastDreamSnippet ?? "Log your dream before you forget it")
                    .font(.callout)
                    .foregroundColor(WidgetColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(WidgetColors.auroraCyan)
                    Text("Tap to log")
                        .font(.caption)
                        .foregroundColor(WidgetColors.auroraCyan)
                }
            }

            // Right: streak
            if entry.streak > 0 {
                VStack(spacing: 8) {
                    Text("\(entry.streak)")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(WidgetColors.auroraCyan)
                    Text("day streak")
                        .font(.caption2)
                        .foregroundColor(WidgetColors.textSecondary)

                    HStack(spacing: 3) {
                        ForEach(0..<min(entry.streak, 7), id: \.self) { _ in
                            Circle()
                                .fill(WidgetColors.auroraCyan)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding()
                .background(WidgetColors.surface)
                .cornerRadius(12)
            }
        }
        .padding(12)
    }

    private var accessoryRectangular: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 1) {
                Text("Dreamscape")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text(entry.lastDreamSnippet ?? "Tap to log")
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
    }

    private var accessoryCircular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "moon.stars.fill")
                    .font(.caption)
                if entry.streak > 0 {
                    Text("\(entry.streak)")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Widget Preview

#Preview("Small", as: .systemSmall) {
    DreamRecallWidget()
} timeline: {
    DreamRecallEntry(
        date: Date(),
        lastDreamSnippet: "I was flying over a golden city at sunset...",
        lastDreamDate: Date(),
        streak: 5,
        configuration: DreamRecallIntent()
    )
}

#Preview("Medium", as: .systemMedium) {
    DreamRecallWidget()
} timeline: {
    DreamRecallEntry(
        date: Date(),
        lastDreamSnippet: "I was flying over a golden city at sunset, the light was incredible...",
        lastDreamDate: Date(),
        streak: 5,
        configuration: DreamRecallIntent()
    )
}
