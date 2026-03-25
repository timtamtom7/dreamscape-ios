import SwiftUI

/// R4: Community View — anonymous social features for dream symbol sharing
struct CommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showingSubmitSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerCard
                            .padding(.horizontal)

                        // Symbol of the day
                        if let symbolOfDay = viewModel.symbolOfTheDay {
                            symbolOfDayCard(symbolOfDay)
                                .padding(.horizontal)
                        }

                        // Search
                        searchBar
                            .padding(.horizontal)

                        // Category filter
                        categoryPicker
                            .padding(.horizontal)

                        // Patterns list
                        patternsList
                            .padding(.horizontal)

                        // Submit button
                        submitButton
                            .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Community")
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
            .sheet(isPresented: $showingSubmitSheet) {
                SubmitSymbolView()
            }
            .sheet(item: $viewModel.selectedPattern) { pattern in
                SymbolInterpretationView(pattern: pattern)
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.nebulaPink)

            Text("Dream Community")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Discover what your symbols mean in the context of thousands of dreamers — completely anonymously")
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

    // MARK: - Symbol of the Day

    private func symbolOfDayCard(_ pattern: CommunityService.CommunityPattern) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Symbol of the Day")
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textMuted)
                    .textCase(.uppercase)
            }

            HStack(spacing: 16) {
                // Symbol circle
                Circle()
                    .fill(AppColors.nebulaPink.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(pattern.category.icon)
                            .font(.title)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.symbolName)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(pattern.topMeaning)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text("\(pattern.percentageOfDreamers)% of dreamers")
                            .font(.caption2)
                            .foregroundColor(AppColors.auroraCyan)

                        Circle()
                            .fill(AppColors.textMuted)
                            .frame(width: 3, height: 3)

                        Text("Tap for details →")
                            .font(.caption2)
                            .foregroundColor(AppColors.textMuted)
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
        .onTapGesture {
            viewModel.selectedPattern = pattern
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textMuted)

            TextField("Search symbols...", text: $viewModel.searchQuery)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryFilterChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    onTap: { viewModel.selectedCategory = nil }
                )

                ForEach(SymbolCategory.allCases) { category in
                    CategoryFilterChip(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        onTap: { viewModel.selectedCategory = category }
                    )
                }
            }
        }
    }

    // MARK: - Patterns List

    private var patternsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Community Patterns")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(viewModel.filteredPatterns.count) symbols")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }

            ForEach(viewModel.filteredPatterns) { pattern in
                CommunityPatternCard(pattern: pattern) {
                    viewModel.selectedPattern = pattern
                }
            }
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: { showingSubmitSheet = true }) {
            HStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3)
                    .foregroundColor(AppColors.backgroundPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Share Your Symbol Anonymously")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.backgroundPrimary)

                    Text("See what others with similar dreams experience")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.backgroundPrimary.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.backgroundPrimary.opacity(0.6))
            }
            .padding(16)
            .background(AppColors.nebulaPink)
            .cornerRadius(16)
        }
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(AppFonts.callout)
                .foregroundColor(isSelected ? AppColors.backgroundPrimary : AppColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.auroraCyan : AppColors.surface)
                )
        }
    }
}

// MARK: - Community Pattern Card

struct CommunityPatternCard: View {
    let pattern: CommunityService.CommunityPattern
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(pattern.category.icon)
                        .font(.title3)

                    Text(pattern.symbolName)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text("\(pattern.percentageOfDreamers)%")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.auroraCyan)
                }

                Text(pattern.topMeaning)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)

                // Interpretation bars
                HStack(spacing: 4) {
                    ForEach(pattern.interpretations.prefix(3)) { interpretation in
                        VStack(spacing: 2) {
                            Text(interpretation.meaning.prefix(12) + (interpretation.meaning.count > 12 ? "..." : ""))
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(1)

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(interpretationColor(interpretation.emotionalTag))
                                    .frame(width: geo.size.width * CGFloat(interpretation.frequency) / 100)
                            }
                            .frame(height: 4)
                        }
                    }
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
        }
    }

    private func interpretationColor(_ tag: String) -> Color {
        switch tag {
        case "Anxiety": return AppColors.warning
        case "Fear": return AppColors.error
        case "Joy", "Empowerment": return AppColors.success
        case "Peace", "Release": return AppColors.auroraCyan
        case "Change", "Mystery", "Awe": return AppColors.nebulaPink
        default: return AppColors.starGold
        }
    }
}

// MARK: - Submit Symbol View

struct SubmitSymbolView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var symbolName = ""
    @State private var selectedCategory: SymbolCategory = .object
    @State private var dreamContext = ""
    @State private var isSubmitting = false
    @State private var submissionResult: CommunityService.AnonymousSymbolSubmission?
    @State private var showingResult = false

    private let communityService = CommunityService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Info card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(AppColors.success)
                                Text("100% Anonymous")
                                    .font(AppFonts.captionBold)
                                    .foregroundColor(AppColors.success)
                            }

                            Text("Your submission is completely anonymous. No accounts, no tracking — just shared dream wisdom.")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Symbol name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dream Symbol")
                                .font(AppFonts.captionBold)
                                .foregroundColor(AppColors.textMuted)
                                .textCase(.uppercase)

                            TextField("e.g., Water, Flying, House", text: $symbolName)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(AppFonts.captionBold)
                                .foregroundColor(AppColors.textMuted)
                                .textCase(.uppercase)

                            Picker("Category", selection: $selectedCategory) {
                                ForEach(SymbolCategory.allCases) { cat in
                                    Label(cat.displayName, systemImage: cat.icon).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.auroraCyan)
                            .padding(12)
                            .background(AppColors.surface)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Context
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dream Context")
                                .font(AppFonts.captionBold)
                                .foregroundColor(AppColors.textMuted)
                                .textCase(.uppercase)

                            TextField("Is this recurring? Recent? Especially vivid?", text: $dreamContext, axis: .vertical)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(3...5)
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Submit button
                        Button(action: submit) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(AppColors.backgroundPrimary)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSubmitting ? "Sharing..." : "Share Anonymously")
                            }
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(symbolName.isEmpty ? AppColors.textMuted : AppColors.nebulaPink)
                            .cornerRadius(12)
                        }
                        .disabled(symbolName.isEmpty || isSubmitting)
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Share Symbol")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
            .sheet(isPresented: $showingResult) {
                if let result = submissionResult {
                    SubmissionResultView(submission: result)
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true

        communityService.submitSymbolAnonymously(
            symbolName: symbolName,
            category: selectedCategory,
            context: dreamContext
        ) { submission in
            isSubmitting = false
            submissionResult = submission
            showingResult = true
        }
    }
}

// MARK: - Submission Result View

struct SubmissionResultView: View {
    @Environment(\.dismiss) private var dismiss
    let submission: CommunityService.AnonymousSymbolSubmission

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Success header
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.success)

                            Text("Shared Successfully!")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Your symbol has been added to the anonymous collective")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.surface)
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // What this means
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What This Symbol May Mean")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text(submission.topInterpretation)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(16)
                                .background(AppColors.surface)
                                .cornerRadius(12)

                            HStack {
                                Text("\(submission.communityPercentage)% of dreamers")
                                    .font(AppFonts.callout)
                                    .foregroundColor(AppColors.auroraCyan)

                                Text("share this symbol")
                                    .font(AppFonts.callout)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Text("Related emotions: \(submission.relatedEmotions.joined(separator: ", "))")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding(.horizontal)

                        // Remember
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(AppColors.starGold)
                                Text("Remember")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Text("These interpretations are community aggregates. Your dream is unique to you — use this as one perspective, not the definitive answer.")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
        }
    }
}

// MARK: - Symbol Interpretation View

struct SymbolInterpretationView: View {
    @Environment(\.dismiss) private var dismiss
    let pattern: CommunityService.CommunityPattern

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Circle()
                                .fill(AppColors.nebulaPink.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(pattern.category.icon)
                                        .font(.largeTitle)
                                )

                            Text(pattern.symbolName)
                                .font(AppFonts.titleMedium)
                                .foregroundColor(AppColors.textPrimary)

                            Text(pattern.topMeaning)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 8) {
                                Image(systemName: "person.3.fill")
                                    .font(.caption)
                                Text("\(pattern.percentageOfDreamers)% of dreamers")
                                    .font(AppFonts.callout)
                            }
                            .foregroundColor(AppColors.auroraCyan)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.surface)
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // Interpretations
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common Interpretations")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            ForEach(pattern.interpretations) { interpretation in
                                InterpretationRow(interpretation: interpretation, totalFrequency: pattern.interpretations.reduce(0) { $0 + $1.frequency })
                            }
                        }
                        .padding(.horizontal)

                        // Tap for help
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppColors.starGold)
                                Text("Dream Recall Tip")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Text("The more emotionally charged a symbol is, the more likely it is to appear repeatedly in your dreams. Notice how this symbol makes you feel.")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Symbol Meaning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
        }
    }
}

// MARK: - Interpretation Row

struct InterpretationRow: View {
    let interpretation: CommunityService.Interpretation
    let totalFrequency: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(interpretation.meaning)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(interpretation.emotionalTag)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.nebulaPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.nebulaPink.opacity(0.2))
                    .cornerRadius(6)
            }

            // Frequency bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.surface)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(interpretation.frequency) / max(CGFloat(totalFrequency), 1))
                }
            }
            .frame(height: 6)

            Text("\(interpretation.frequency)% of interpretations")
                .font(.caption2)
                .foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private var barColor: Color {
        switch interpretation.emotionalTag {
        case "Anxiety", "Fear", "Stress": return AppColors.error
        case "Joy", "Empowerment", "Hope": return AppColors.success
        case "Peace", "Release", "Awe": return AppColors.auroraCyan
        case "Change", "Mystery", "Confusion": return AppColors.nebulaPink
        default: return AppColors.starGold
        }
    }
}

// MARK: - View Model

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var symbolOfTheDay: CommunityService.CommunityPattern?
    @Published var allPatterns: [CommunityService.CommunityPattern] = []
    @Published var filteredPatterns: [CommunityService.CommunityPattern] = []
    @Published var searchQuery = ""
    @Published var selectedCategory: SymbolCategory?
    @Published var selectedPattern: CommunityService.CommunityPattern?
    @Published var userSymbols: [Symbol] = []

    private let communityService = CommunityService.shared
    private let databaseService = DatabaseService.shared

    func loadData() {
        do {
            userSymbols = try databaseService.fetchAllSymbols()
            symbolOfTheDay = communityService.getSymbolOfTheDay(userSymbols: userSymbols)
            allPatterns = communityService.getPatterns()
            applyFilters()
        } catch {
            print("Load error: \(error)")
        }
    }

    func applyFilters() {
        var patterns = allPatterns

        if let category = selectedCategory {
            patterns = patterns.filter { $0.category == category }
        }

        if !searchQuery.isEmpty {
            patterns = communityService.searchPatterns(query: searchQuery)
            if let category = selectedCategory {
                patterns = patterns.filter { $0.category == category }
            }
        }

        filteredPatterns = patterns
    }
}

#Preview {
    CommunityView()
}
