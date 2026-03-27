import SwiftUI

/// R4: Sleep Lab View — comprehensive sleep environment logging
struct SleepLabView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SleepLabViewModel()
    @State private var showingExportSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerCard
                            .padding(.horizontal)

                        // Log last night's sleep
                        sleepLogForm
                            .padding(.horizontal)

                        // AI Insights
                        if !viewModel.insights.isEmpty {
                            insightsSection
                                .padding(.horizontal)
                        }

                        // Optimization tips
                        if !viewModel.tips.isEmpty {
                            tipsSection
                                .padding(.horizontal)
                        }

                        // Recent records
                        if !viewModel.records.isEmpty {
                            recentRecordsSection
                                .padding(.horizontal)
                        }

                        // Dream Journal Export CTA
                        exportCTACard
                            .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Sleep Lab")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingExportSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.nebulaPink)
                    }
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .sheet(isPresented: $showingExportSheet) {
                DreamJournalExportView()
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.nebulaPink)

            Text("Sleep Lab")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Track your sleep environment to unlock dream insights")
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

    // MARK: - Sleep Log Form

    private var sleepLogForm: some View {
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
                        Button(action: {
                            HapticFeedback.selection()
                            viewModel.selectedQuality = quality
                        }) {
                            Text(quality.emoji)
                                .font(.title2)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.selectedQuality == quality ? Color(hex: quality.color).opacity(0.3) : AppColors.surfaceElevated)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.selectedQuality == quality ? Color(hex: quality.color) : Color.clear, lineWidth: 2)
                                )
                        }
                        .accessibilityLabel("\(quality.displayName) sleep quality")
                        .accessibilityAddTraits(viewModel.selectedQuality == quality ? [.isButton, .isSelected] : .isButton)
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

            Divider().background(AppColors.surfaceElevated)

            // Environment Section
            Text("Sleep Environment")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)

            // Mattress type
            VStack(alignment: .leading, spacing: 8) {
                Text("Mattress Type")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MattressType.allCases) { type in
                            Button(action: {
                                HapticFeedback.selection()
                                viewModel.selectedMattress = type
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(AppFonts.caption)
                                    Text(type.displayName)
                                        .font(AppFonts.captionSmall)
                                }
                                .foregroundColor(viewModel.selectedMattress == type ? AppColors.auroraCyan : AppColors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.selectedMattress == type ? AppColors.auroraCyan.opacity(0.2) : AppColors.surfaceElevated)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.selectedMattress == type ? AppColors.auroraCyan : Color.clear, lineWidth: 1)
                                )
                            }
                            .accessibilityLabel("\(type.displayName) mattress")
                            .accessibilityAddTraits(viewModel.selectedMattress == type ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                }
            }

            // Room temperature
            VStack(alignment: .leading, spacing: 8) {
                Text("Room Temperature: \(viewModel.selectedTemperature.displayName)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                Picker("Temperature", selection: $viewModel.selectedTemperature) {
                    ForEach(RoomTemperature.allCases) { temp in
                        Text(temp.displayName).tag(temp)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.auroraCyan)
            }

            // Sound level
            VStack(alignment: .leading, spacing: 8) {
                Text("Sound Level")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                HStack(spacing: 8) {
                    ForEach(SoundLevel.allCases) { sound in
                        Button(action: {
                            HapticFeedback.selection()
                            viewModel.selectedSound = sound
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: sound.icon)
                                    .font(AppFonts.caption)
                                Text(sound.displayName)
                                    .font(AppFonts.captionSmall)
                            }
                            .foregroundColor(viewModel.selectedSound == sound ? AppColors.nebulaPink : AppColors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewModel.selectedSound == sound ? AppColors.nebulaPink.opacity(0.2) : AppColors.surfaceElevated)
                            )
                        }
                        .accessibilityLabel("\(sound.displayName) sound level")
                        .accessibilityAddTraits(viewModel.selectedSound == sound ? [.isButton, .isSelected] : .isButton)
                    }
                }
            }

            // Light level
            VStack(alignment: .leading, spacing: 8) {
                Text("Light Level")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                Picker("Light", selection: $viewModel.selectedLight) {
                    ForEach(LightLevel.allCases) { light in
                        Label(light.displayName, systemImage: light.icon).tag(light)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.starGold)
            }

            // Food before bed
            VStack(alignment: .leading, spacing: 8) {
                Text("Food Before Bed")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FoodBeforeBed.allCases) { food in
                            Button(action: {
                                HapticFeedback.selection()
                                viewModel.selectedFood = food
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: food.icon)
                                        .font(AppFonts.caption)
                                    Text(food.displayName)
                                        .font(AppFonts.captionSmall)
                                }
                                .foregroundColor(viewModel.selectedFood == food ? AppColors.success : AppColors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.selectedFood == food ? AppColors.success.opacity(0.2) : AppColors.surfaceElevated)
                                )
                            }
                            .accessibilityLabel("\(food.displayName) food before bed")
                            .accessibilityAddTraits(viewModel.selectedFood == food ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                }
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

            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)

                TextField("Any additional notes...", text: $viewModel.notes, axis: .vertical)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(3...5)
                    .padding(12)
                    .background(AppColors.surfaceElevated)
                    .cornerRadius(12)
            }

            // Save button
            Button(action: {
                HapticFeedback.success()
                viewModel.saveRecord()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Sleep Log")
                }
                .font(AppFonts.callout)
                .foregroundColor(AppColors.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.auroraCyan)
                .cornerRadius(DesignTokens.CornerRadius.medium)
            }
            .accessibilityLabel("Save Sleep Log")
            .accessibilityHint("Double tap to save your sleep record")
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.starGold)
                Text("AI Sleep Insights")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(viewModel.insights) { insight in
                InsightCard(insight: insight)
            }
        }
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Sleep Setup Optimization")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(viewModel.tips) { tip in
                TipCard(tip: tip)
            }
        }
    }

    // MARK: - Recent Records

    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Sleep Logs")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            ForEach(viewModel.records.prefix(5)) { record in
                SleepLabRecordRow(record: record)
            }
        }
    }

    // MARK: - Export CTA

    private var exportCTACard: some View {
        Button(action: {
            HapticFeedback.light()
            showingExportSheet = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: "doc.richtext.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.nebulaPink)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Dream Journal")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Create a beautiful PDF book of your dream journey")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(DesignTokens.CornerRadius.large)
        }
        .accessibilityLabel("Export Dream Journal")
        .accessibilityHint("Create a beautiful PDF book of your dream journey")
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let tip: SleepSetupTip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tip.category.rawValue)
                    .font(AppFonts.caption)
                    .foregroundColor(impactColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(impactColor.opacity(0.2))
                    .cornerRadius(6)

                Spacer()

                Text(tip.impact.rawValue)
                    .font(.caption2)
                    .foregroundColor(AppColors.textMuted)
            }

            Text(tip.title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(tip.description)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var impactColor: Color {
        switch tip.impact {
        case .high: return AppColors.error
        case .medium: return AppColors.warning
        case .low: return AppColors.success
        }
    }
}

// MARK: - Sleep Lab Record Row

struct SleepLabRecordRow: View {
    let record: SleepLabRecord

    var body: some View {
        HStack {
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

                    if let temp = record.roomTemperature {
                        HStack(spacing: 4) {
                            Image(systemName: "thermometer")
                                .font(.caption2)
                            Text(temp.displayName)
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(AppColors.textMuted)
                    }

                    if let sound = record.soundLevel {
                        HStack(spacing: 4) {
                            Image(systemName: sound.icon)
                                .font(.caption2)
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
final class SleepLabViewModel: ObservableObject {
    @Published var records: [SleepLabRecord] = []
    @Published var insights: [SleepCorrelationInsight] = []
    @Published var tips: [SleepSetupTip] = []

    @Published var selectedQuality: SleepQuality = .good
    @Published var hoursSlept: Double = 7.0
    @Published var selectedMattress: MattressType?
    @Published var selectedTemperature: RoomTemperature = .ideal
    @Published var selectedSound: SoundLevel?
    @Published var selectedLight: LightLevel = .completeDarkness
    @Published var selectedFood: FoodBeforeBed?
    @Published var screenTime: Int = 30
    @Published var notes: String = ""
    @Published var isLoading = false

    private let sleepLabService = SleepLabService.shared
    private let databaseService = DatabaseService.shared

    func loadData() {
        isLoading = true

        do {
            records = try sleepLabService.fetchAllRecords()
            let dreams = try databaseService.fetchAllDreams()
            insights = sleepLabService.generateCorrelationInsights(records: records, dreamCount: dreams.count)
            tips = sleepLabService.generateSetupTips(records: records)
        } catch {
            print("Load error: \(error)")
        }

        isLoading = false
    }

    func saveRecord() {
        let record = SleepLabRecord(
            mattressType: selectedMattress,
            roomTemperature: selectedTemperature,
            soundLevel: selectedSound,
            lightLevel: selectedLight,
            foodBeforeBed: selectedFood,
            screenTimeBeforeBed: screenTime > 0 ? screenTime : nil,
            quality: selectedQuality,
            hoursSlept: hoursSlept,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            try sleepLabService.saveRecord(record)
            records.insert(record, at: 0)

            // Regenerate insights and tips
            let dreams = try databaseService.fetchAllDreams()
            insights = sleepLabService.generateCorrelationInsights(records: records, dreamCount: dreams.count)
            tips = sleepLabService.generateSetupTips(records: records)
        } catch {
            print("Save error: \(error)")
        }

        // Reset form
        resetForm()
    }

    private func resetForm() {
        selectedQuality = .good
        hoursSlept = 7.0
        selectedMattress = nil
        selectedTemperature = .ideal
        selectedSound = nil
        selectedLight = .completeDarkness
        selectedFood = nil
        screenTime = 30
        notes = ""
    }
}

#Preview {
    SleepLabView()
}
