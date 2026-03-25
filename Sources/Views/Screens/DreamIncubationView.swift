import SwiftUI

struct DreamIncubationView: View {
    @StateObject private var incubationStore = IncubationStore.shared
    @State private var showingNewIncubation = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Success rate header
                    if incubationStore.completedIncubations.count > 0 {
                        successRateHeader
                    }

                    // Tab picker
                    Picker("", selection: $selectedTab) {
                        Text("Active").tag(0)
                        Text("History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if selectedTab == 0 {
                        activeIncubationsView
                    } else {
                        historyView
                    }
                }
            }
            .navigationTitle("Dream Incubation")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewIncubation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(isPresented: $showingNewIncubation) {
                NewIncubationSheet()
            }
        }
    }

    private var successRateHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(AppColors.starGold)
                Text("Incubation Success Rate")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("\(Int(incubationStore.successRate))%")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.starGold)
            }

            ProgressView(value: incubationStore.successRate, total: 100)
                .tint(AppColors.starGold)
                .tint(AppColors.auroraCyan)
        }
        .padding()
        .background(AppColors.surface)
    }

    private var activeIncubationsView: some View {
        ScrollView {
            if incubationStore.activeIncubations.isEmpty {
                emptyActiveState
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(incubationStore.activeIncubations) { incubation in
                        IncubationCard(incubation: incubation)
                    }
                }
                .padding()
            }
        }
    }

    private var emptyActiveState: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars")
                .font(.system(size: 64))
                .foregroundColor(AppColors.textMuted)

            Text("Set Your Intention")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("Plant a seed in your subconscious before sleep. What do you want to dream about tonight?")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showingNewIncubation = true
            } label: {
                Label("Create Intention", systemImage: "plus.circle.fill")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.backgroundPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.auroraCyan)
                    .cornerRadius(25)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var historyView: some View {
        ScrollView {
            if incubationStore.completedIncubations.isEmpty {
                Text("No completed incubations yet")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(incubationStore.completedIncubations) { incubation in
                        CompletedIncubationCard(incubation: incubation)
                    }
                }
                .padding()
            }
        }
    }
}

struct IncubationCard: View {
    let incubation: DreamIncubation
    @State private var showingComplete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(AppColors.nebulaPink)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tonight's Intention")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(incubation.targetDate.formatted(date: .abbreviated, time: .omitted))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.auroraCyan)
                }

                Spacer()

                Button {
                    showingComplete = true
                } label: {
                    Text("Complete")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.backgroundPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.auroraCyan)
                        .cornerRadius(12)
                }
            }

            Text(incubation.intention)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            if let refined = incubation.aiRefinedIntention {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Refined:")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.nebulaPink)
                    Text(refined)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.textSecondary)
                        .italic()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
        .sheet(isPresented: $showingComplete) {
            CompleteIncubationSheet(incubation: incubation)
        }
    }
}

struct CompletedIncubationCard: View {
    let incubation: DreamIncubation

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(incubation.wasSuccessful == true ? AppColors.success.opacity(0.2) : AppColors.error.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: incubation.wasSuccessful == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(incubation.wasSuccessful == true ? AppColors.success : AppColors.error)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(incubation.intention)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(incubation.targetDate.formatted(date: .abbreviated, time: .omitted))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            if incubation.wasSuccessful == true {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.starGold)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }
}

struct NewIncubationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var analysisService = DreamAnalysisService.shared
    @State private var intentionText = ""
    @State private var refinedIntention = ""
    @State private var isRefining = false
    @State private var showRefined = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("What do you want to dream about?")
                            .font(AppFonts.titleSmall)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Set a clear intention before sleep. The subconscious mind responds well to specific, positive phrasing.")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)

                        TextEditor(text: $intentionText)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)

                        Button {
                            refineIntention()
                        } label: {
                            HStack {
                                if isRefining {
                                    ProgressView()
                                        .tint(AppColors.backgroundPrimary)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                }
                                Text(isRefining ? "Refining..." : "AI Refine Intention")
                            }
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.nebulaPink)
                            .cornerRadius(12)
                        }
                        .disabled(intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 || isRefining)

                        if showRefined && !refinedIntention.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Refined Intention")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.nebulaPink)

                                Text(refinedIntention)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.nebulaPink.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("New Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        saveIncubation()
                    }
                    .disabled(intentionText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                }
            }
        }
    }

    private func refineIntention() {
        isRefining = true
        Task {
            let refined = await analysisService.refineIncubationIntention(intentionText)
            await MainActor.run {
                refinedIntention = refined
                showRefined = true
                isRefining = false
            }
        }
    }

    private func saveIncubation() {
        let incubation = DreamIncubation(
            intention: intentionText,
            aiRefinedIntention: showRefined ? refinedIntention : nil
        )
        IncubationStore.shared.add(incubation)
        dismiss()
    }
}

struct CompleteIncubationSheet: View {
    let incubation: DreamIncubation
    @Environment(\.dismiss) private var dismiss
    @State private var wasSuccessful: Bool? = nil
    @State private var notes = ""
    @State private var selectedDreamId: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Did you dream about your intention?")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: 16) {
                        successButton(helped: true)
                        successButton(helped: false)
                    }

                    if wasSuccessful == false {
                        Text("What did you dream about instead? (optional)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        TextEditor(text: $notes)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Log Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveResult()
                    }
                    .disabled(wasSuccessful == nil)
                }
            }
        }
    }

    private func successButton(helped: Bool) -> some View {
        Button {
            wasSuccessful = helped
        } label: {
            VStack(spacing: 8) {
                Image(systemName: helped ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 40))
                Text(helped ? "Yes!" : "No")
                    .font(AppFonts.headline)
            }
            .foregroundColor(wasSuccessful == helped ? AppColors.backgroundPrimary : (helped ? AppColors.success : AppColors.error))
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                (wasSuccessful == helped)
                    ? (helped ? AppColors.success : AppColors.error)
                    : AppColors.surface
            )
            .cornerRadius(16)
        }
    }

    private func saveResult() {
        IncubationStore.shared.markCompleted(
            incubationId: incubation.id,
            relatedDreamId: nil,
            wasSuccessful: wasSuccessful ?? false,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}
