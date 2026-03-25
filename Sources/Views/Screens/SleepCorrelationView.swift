import SwiftUI

/// R3: Sleep Correlation View — shows how dreams correlate with sleep quality
struct SleepCorrelationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SleepCorrelationViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerCard
                            .padding(.horizontal)

                        // Quick sleep log
                        sleepLogSection
                            .padding(.horizontal)

                        // Insights
                        if !viewModel.insights.isEmpty {
                            insightsSection
                                .padding(.horizontal)
                        }

                        // Recent sleep records
                        if !viewModel.sleepRecords.isEmpty {
                            recentSleepSection
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Sleep & Dreams")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.nebulaPink)

            Text("Sleep & Dream Correlation")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Track how your sleep quality affects your dreams")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.surface, AppColors.surfaceElevated],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.nebulaPink.opacity(0.3), lineWidth: 1)
        )
    }

    private var sleepLogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Log Last Night's Sleep")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            // Quality picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Sleep Quality")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                HStack(spacing: 8) {
                    ForEach(SleepQuality.allCases) { quality in
                        Button(action: { viewModel.selectedQuality = quality }) {
                            Text(quality.emoji)
                                .font(.title2)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.selectedQuality == quality ? Color(hex: quality.color).opacity(0.3) : AppColors.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.selectedQuality == quality ? Color(hex: quality.color) : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }

            // Hours slept
            VStack(alignment: .leading, spacing: 8) {
                Text("Hours Slept: \(String(format: "%.1f", viewModel.hoursSlept))")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                Slider(value: $viewModel.hoursSlept, in: 0...12, step: 0.5)
                    .tint(AppColors.auroraCyan)
            }

            // Screen time
            VStack(alignment: .leading, spacing: 8) {
                Text("Screen time before bed: \(viewModel.screenTime) min")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                Slider(value: Binding(
                    get: { Double(viewModel.screenTime) },
                    set: { viewModel.screenTime = Int($0) }
                ), in: 0...180, step: 15)
                .tint(AppColors.nebulaPink)
            }

            // Save button
            Button(action: { viewModel.saveSleepRecord() }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Sleep Record")
                }
                .font(AppFonts.callout)
                .foregroundColor(AppColors.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.auroraCyan)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.starGold)
                Text("AI Insights")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(viewModel.insights) { insight in
                InsightCard(insight: insight)
            }
        }
    }

    private var recentSleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Sleep Records")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            ForEach(viewModel.sleepRecords.prefix(7)) { record in
                SleepRecordRow(record: record)
            }
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: SleepCorrelationInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForType(insight.type))
                    .foregroundColor(AppColors.starGold)

                Text(insight.title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text(insight.description)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Confidence indicator
            HStack {
                Text("Confidence:")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.surface)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.auroraCyan)
                            .frame(width: geometry.size.width * insight.confidence, height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(Int(insight.confidence * 100))%")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func iconForType(_ type: SleepCorrelationInsight.InsightType) -> String {
        switch type {
        case .screenTimeCorrelation: return "iphone.slash"
        case .moodCorrelation: return "heart.slash"
        case .recurringDreamImpact: return "repeat"
        case .bestSleepPattern: return "bed.double.fill"
        }
    }
}

// MARK: - Sleep Record Row

struct SleepRecordRow: View {
    let record: SleepData

    var body: some View {
        HStack {
            // Quality emoji
            Text(record.quality.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.formattedDate)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .font(.caption2)
                        Text("\(String(format: "%.1f", record.hoursSlept))h")
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(AppColors.textMuted)

                    if let screenTime = record.screenTimeBeforeBed {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                                .font(.caption2)
                            Text("\(screenTime)m")
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(AppColors.textMuted)
                    }
                }
            }

            Spacer()

            Circle()
                .fill(Color(hex: record.quality.color))
                .frame(width: 10, height: 10)
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

// MARK: - View Model

@MainActor
final class SleepCorrelationViewModel: ObservableObject {
    @Published var sleepRecords: [SleepData] = []
    @Published var insights: [SleepCorrelationInsight] = []
    @Published var selectedQuality: SleepQuality = .good
    @Published var hoursSlept: Double = 7.0
    @Published var screenTime: Int = 30
    @Published var isLoading = false

    private let sleepDataService = SleepDataService.shared
    private let databaseService = DatabaseService.shared

    func loadData() {
        isLoading = true

        do {
            sleepRecords = try sleepDataService.fetchAllSleepRecords()
            let dreams = try databaseService.fetchAllDreams()
            insights = sleepDataService.generateInsights(dreams: dreams, sleepRecords: sleepRecords)
        } catch {
            print("Load error: \(error)")
        }

        isLoading = false
    }

    func saveSleepRecord() {
        let record = SleepData(
            quality: selectedQuality,
            hoursSlept: hoursSlept,
            screenTimeBeforeBed: screenTime > 0 ? screenTime : nil
        )

        do {
            try sleepDataService.saveSleepRecord(record)
            sleepRecords.insert(record, at: 0)

            // Regenerate insights
            let dreams = try databaseService.fetchAllDreams()
            insights = sleepDataService.generateInsights(dreams: dreams, sleepRecords: sleepRecords)
        } catch {
            print("Save error: \(error)")
        }

        // Reset form
        selectedQuality = .good
        hoursSlept = 7.0
        screenTime = 30
    }
}

#Preview {
    SleepCorrelationView()
}
