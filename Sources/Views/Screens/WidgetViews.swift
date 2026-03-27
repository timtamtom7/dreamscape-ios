import SwiftUI

/// R4: Widget Views — in-app widget surfaces for dream recall and symbol of the day
/// These are shown on the lock screen / notification center style areas

// MARK: - Dream Recall Widget

struct DreamRecallWidgetView: View {
    @Binding var showingEntrySheet: Bool
    @State private var lastDreamDate: Date?
    @State private var lastDreamSnippet: String = ""

    private let databaseService = DatabaseService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Dream Recall")
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(widgetDate)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("What did you dream about last night?")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                if !lastDreamSnippet.isEmpty {
                    Text("Last dream: \(lastDreamSnippet)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                } else {
                    Text("Tap to log your dream before you forget it")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Quick log button
                Button(action: {
                    HapticFeedback.medium()
                    showingEntrySheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text(lastDreamSnippet.isEmpty ? "Log Dream" : "Add Another")
                    }
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.backgroundPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.auroraCyan)
                    .cornerRadius(20)
                }
                .accessibilityLabel(lastDreamSnippet.isEmpty ? "Log Dream" : "Add Another Dream")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                .fill(AppColors.surface)
        )
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .onAppear { loadLastDream() }
    }

    private var widgetDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    private func loadLastDream() {
        do {
            let dreams = try databaseService.fetchAllDreams()
            if let lastDream = dreams.first {
                lastDreamDate = lastDream.createdAt
                let preview = lastDream.summary.isEmpty ? lastDream.content : lastDream.summary
                lastDreamSnippet = String(preview.prefix(80)) + (preview.count > 80 ? "..." : "")
            }
        } catch {
            print("Load error: \(error)")
        }
    }
}

// MARK: - Symbol of the Day Widget

struct SymbolOfTheDayWidgetView: View {
    @State private var symbolPattern: CommunityService.CommunityPattern?
    @State private var showingCommunity = false

    private let communityService = CommunityService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Symbol of the Day")
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Content
            if let pattern = symbolPattern {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppColors.nebulaPink.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(pattern.category.icon)
                                    .font(.title3)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(pattern.symbolName)
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("\(pattern.percentageOfDreamers)% of dreamers")
                                .font(.caption2)
                                .foregroundColor(AppColors.auroraCyan)
                        }

                        Spacer()
                    }

                    Text(pattern.topMeaning)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)

                    // Quick interpretations
                    HStack(spacing: 6) {
                        ForEach(pattern.interpretations.prefix(2)) { interp in
                            Text(interp.meaning.prefix(15) + (interp.meaning.count > 15 ? "..." : ""))
                                .font(.caption2)
                                .foregroundColor(AppColors.nebulaPink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.nebulaPink.opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Loading today's symbol...")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
        .padding(.horizontal, 16)
        .onAppear { loadSymbolOfDay() }
    }

    private func loadSymbolOfDay() {
        symbolPattern = communityService.getSymbolOfTheDay(userSymbols: [])
    }
}

// MARK: - Sleep Quality Widget

struct SleepQualityWidgetView: View {
    @State private var lastRecord: SleepLabRecord?

    private let sleepLabService = SleepLabService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "bed.double.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Sleep Quality")
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Content
            if let record = lastRecord {
                HStack(spacing: 16) {
                    Text(record.quality.emoji)
                        .font(.largeTitle)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Night")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "moon.fill")
                                    .font(.caption2)
                                Text("\(String(format: "%.1f", record.hoursSlept))h")
                                    .font(AppFonts.callout)
                            }
                            .foregroundColor(AppColors.textSecondary)

                            if let temp = record.roomTemperature {
                                HStack(spacing: 4) {
                                    Image(systemName: "thermometer")
                                        .font(.caption2)
                                    Text(temp.displayName)
                                        .font(AppFonts.callout)
                                }
                                .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }

                    Spacer()

                    Circle()
                        .fill(Color(hex: record.quality.color))
                        .frame(width: 12, height: 12)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No sleep data yet")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)

                    Text("Log your sleep in Sleep Lab")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
        .padding(.horizontal, 16)
        .onAppear { loadLastRecord() }
    }

    private func loadLastRecord() {
        do {
            lastRecord = try sleepLabService.fetchRecord(for: Date())
        } catch {
            print("Load error: \(error)")
        }
    }
}

// MARK: - Dream Streak Widget

struct DreamStreakWidgetView: View {
    @State private var currentStreak: Int = 0
    @State private var longestStreak: Int = 0

    private let databaseService = DatabaseService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Dream Streak")
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Content
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(currentStreak)")
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.auroraCyan)
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(AppColors.textMuted)
                }

                VStack(spacing: 4) {
                    Text("\(longestStreak)")
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.starGold)
                    Text("Longest")
                        .font(.caption2)
                        .foregroundColor(AppColors.textMuted)
                }

                Spacer()

                // Streak visualization
                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { day in
                        Circle()
                            .fill(day < currentStreak ? AppColors.auroraCyan : AppColors.surfaceElevated)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
        .padding(.horizontal, 16)
        .onAppear { calculateStreaks() }
    }

    private func calculateStreaks() {
        do {
            let dreams = try databaseService.fetchAllDreams()
            let calendar = Calendar.current

            var streak = 0
            var maxStreak = 0
            var currentDate = Date()

            for _ in 0..<30 {
                let hasDream = dreams.contains { dream in
                    calendar.isDate(dream.createdAt, inSameDayAs: currentDate)
                }

                if hasDream {
                    streak += 1
                    maxStreak = max(maxStreak, streak)
                } else {
                    if streak > 0 {
                        maxStreak = max(maxStreak, streak)
                    }
                    streak = 0
                }

                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }

            currentStreak = streak
            longestStreak = maxStreak
        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Widget Dashboard (combined view)

struct WidgetDashboardView: View {
    @Binding var showingEntrySheet: Bool
    @State private var showingSleepLab = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                DreamRecallWidgetView(showingEntrySheet: $showingEntrySheet)
                    .frame(width: 280)

                SymbolOfTheDayWidgetView()
                    .frame(width: 280)

                SleepQualityWidgetView()
                    .frame(width: 280)

                DreamStreakWidgetView()
                    .frame(width: 280)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()

        VStack(spacing: 16) {
            DreamRecallWidgetView(showingEntrySheet: .constant(false))
            SymbolOfTheDayWidgetView()
            SleepQualityWidgetView()
            DreamStreakWidgetView()
        }
    }
}
