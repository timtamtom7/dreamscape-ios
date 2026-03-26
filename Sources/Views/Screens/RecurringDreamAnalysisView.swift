import SwiftUI

/// R3: Recurring Dream Analysis — deep dive into recurring dream patterns
struct RecurringDreamAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecurringAnalysisViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Summary
                        summaryCard
                            .padding(.horizontal)

                        // Dream families
                        if !viewModel.dreamFamilies.isEmpty {
                            dreamFamiliesSection
                                .padding(.horizontal)
                        }

                        // Evolution timeline
                        if !viewModel.evolutionData.isEmpty {
                            evolutionSection
                                .padding(.horizontal)
                        }

                        // Shared symbols
                        if !viewModel.sharedSymbols.isEmpty {
                            sharedSymbolsSection
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Dream Patterns")
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
                viewModel.analyze()
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.starGold)

            Text("Dream Pattern Analysis")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("Dreamscape has identified \(viewModel.dreamFamilies.count) recurring dream family\(viewModel.dreamFamilies.count == 1 ? "" : "ies") across your journal.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.starGold.opacity(0.15), AppColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.starGold.opacity(0.3), lineWidth: 1)
        )
    }

    private var dreamFamiliesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "family.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Dream Families")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(viewModel.dreamFamilies, id: \.id) { family in
                DreamFamilyCard(family: family)
            }
        }
    }

    private var evolutionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Symbol Evolution")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("How often key symbols have appeared over time")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            ForEach(viewModel.evolutionData.prefix(5), id: \.symbolName) { data in
                SymbolEvolutionRow(data: data)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var sharedSymbolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Frequently Connected Symbols")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("These symbol pairs often appear together in your dreams")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            ForEach(viewModel.sharedSymbols.prefix(5), id: \.id) { pair in
                SymbolPairRow(pair: pair)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }
}

// MARK: - Dream Family

struct DreamFamily: Identifiable {
    let id: UUID
    let variantId: UUID
    let dreams: [Dream]
    let sharedTheme: String
    let commonSymbols: [Symbol]

    var title: String {
        if let first = dreams.first {
            let words = first.content.components(separatedBy: .whitespacesAndNewlines).prefix(5)
            return words.joined(separator: " ") + (first.content.count > 30 ? "..." : "")
        }
        return "Unknown Dream"
    }
}

struct DreamFamilyCard: View {
    let family: DreamFamily
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(family.title)
                                .font(AppFonts.callout)
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)

                            Spacer()

                            Text("\(family.dreams.count) dreams")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.starGold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.starGold.opacity(0.15))
                                .cornerRadius(999)
                        }

                        Text("Theme: \(family.sharedTheme)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(family.dreams.sorted(by: { $0.createdAt > $1.createdAt })) { dream in
                        HStack {
                            Text(dream.shortFormattedDate)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.auroraCyan)

                            Text(dream.summary.isEmpty ? dream.content.truncated(to: 60) : dream.summary)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(1)

                            Spacer()

                            if dream.isLucid {
                                Image(systemName: "eye.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.nebulaPink)
                            }
                        }
                        .padding(8)
                        .background(AppColors.surfaceElevated)
                        .cornerRadius(8)
                    }
                }

                // Common symbols
                if !family.commonSymbols.isEmpty {
                    HStack {
                        Text("Common symbols:")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)

                        FlowLayout(spacing: 4) {
                            ForEach(family.commonSymbols.prefix(4)) { symbol in
                                HStack(spacing: 2) {
                                    Image(systemName: symbol.category.icon)
                                        .font(.caption2)
                                    Text(symbol.name)
                                        .font(AppFonts.caption)
                                }
                                .foregroundColor(symbol.category.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(symbol.category.color.opacity(0.15))
                                .cornerRadius(999)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }
}

// MARK: - Symbol Evolution

struct SymbolEvolutionData {
    let symbolName: String
    let category: SymbolCategory
    let occurrencesByMonth: [String: Int] // e.g. "Jan": 3, "Feb": 7
}

struct SymbolEvolutionRow: View {
    let data: SymbolEvolutionData

    private var maxCount: Int {
        data.occurrencesByMonth.values.max() ?? 1
    }

    private var sortedMonths: [(String, Int)] {
        data.occurrencesByMonth.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: data.category.icon)
                    .font(.caption2)
                    .foregroundColor(data.category.color)
                Text(data.symbolName)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textPrimary)
            }

            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(sortedMonths, id: \.0) { month, count in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(data.category.color)
                                .frame(
                                    width: (geometry.size.width - CGFloat(sortedMonths.count - 1) * 4) / CGFloat(max(sortedMonths.count, 1)),
                                    height: CGFloat(count) / CGFloat(max(maxCount, 1)) * 40 + 4
                                )

                            Text(month)
                                .font(.system(size: 8))
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                }
            }
            .frame(height: 60)
        }
        .padding(12)
        .background(AppColors.surfaceElevated)
        .cornerRadius(12)
    }
}

// MARK: - Symbol Pair

struct SymbolPair: Identifiable {
    let id = UUID()
    let symbol1: Symbol
    let symbol2: Symbol
    let coOccurrenceCount: Int
}

struct SymbolPairRow: View {
    let pair: SymbolPair

    var body: some View {
        HStack {
            HStack(spacing: -6) {
                Circle()
                    .fill(pair.symbol1.category.color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: pair.symbol1.category.icon)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )

                Circle()
                    .fill(pair.symbol2.category.color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: pair.symbol2.category.icon)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(pair.symbol1.name) + \(pair.symbol2.name)")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textPrimary)

                Text("\(pair.coOccurrenceCount) shared dreams")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text("\(pair.coOccurrenceCount)x")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.nebulaPink)
        }
        .padding(10)
        .background(AppColors.surfaceElevated)
        .cornerRadius(10)
    }
}

// MARK: - View Model

@MainActor
final class RecurringAnalysisViewModel: ObservableObject {
    @Published var dreamFamilies: [DreamFamily] = []
    @Published var evolutionData: [SymbolEvolutionData] = []
    @Published var sharedSymbols: [SymbolPair] = []
    @Published var isLoading = false

    private let databaseService = DatabaseService.shared

    func analyze() {
        isLoading = true

        do {
            let dreams = try databaseService.fetchAllDreams()
            analyzeDreamFamilies(dreams)
            analyzeSymbolEvolution(dreams)
            analyzeSymbolPairs(dreams)
        } catch {
            print("Analysis error: \(error)")
        }

        isLoading = false
    }

    private func analyzeDreamFamilies(_ dreams: [Dream]) {
        var families: [UUID: [Dream]] = [:]

        for dream in dreams {
            let variantId = dream.recurringVariantId ?? dream.id
            families[variantId, default: []].append(dream)
        }

        dreamFamilies = families.values
            .filter { $0.count > 1 }
            .map { dreamsInFamily in
                let allSymbols = dreamsInFamily.flatMap { $0.symbols }
                let symbolCounts = Dictionary(grouping: allSymbols, by: { $0.name })
                    .mapValues { $0.count }
                    .sorted { $0.value > $1.value }
                    .prefix(3)
                    .compactMap { name, _ in allSymbols.first { $0.name == name } }

                let themes = detectSharedTheme(dreamsInFamily)

                return DreamFamily(
                    id: UUID(),
                    variantId: dreamsInFamily.first?.recurringVariantId ?? dreamsInFamily.first?.id ?? UUID(),
                    dreams: dreamsInFamily,
                    sharedTheme: themes.joined(separator: ", "),
                    commonSymbols: Array(symbolCounts)
                )
            }
            .sorted { $0.dreams.count > $1.dreams.count }
    }

    private func detectSharedTheme(_ dreams: [Dream]) -> [String] {
        var themes: [String: Int] = [:]

        for dream in dreams {
            for symbol in dream.symbols {
                themes[symbol.category.displayName, default: 0] += 1
            }
        }

        return themes
            .sorted { $0.value > $1.value }
            .prefix(2)
            .map { $0.key }
    }

    private func analyzeSymbolEvolution(_ dreams: [Dream]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        var symbolMonthCounts: [String: [String: Int]] = [:]

        for dream in dreams {
            let month = dateFormatter.string(from: dream.createdAt)

            for symbol in dream.symbols {
                symbolMonthCounts[symbol.name, default: [:]][month, default: 0] += 1
            }
        }

        evolutionData = symbolMonthCounts
            .filter { $0.value.values.reduce(0, +) >= 2 }
            .sorted { $0.value.values.reduce(0, +) > $1.value.values.reduce(0, +) }
            .prefix(6)
            .map { name, months in
                let category = dreams
                    .flatMap { $0.symbols }
                    .first { $0.name == name }?.category ?? .emotion
                return SymbolEvolutionData(symbolName: name, category: category, occurrencesByMonth: months)
            }
    }

    private func analyzeSymbolPairs(_ dreams: [Dream]) {
        var pairCounts: [String: (Symbol, Symbol, Int)] = [:]

        for dream in dreams {
            let symbols = dream.symbols
            for i in 0..<symbols.count {
                for j in (i+1)..<symbols.count {
                    let key = [symbols[i].name, symbols[j].name].sorted().joined(separator: "||")
                    if let existing = pairCounts[key] {
                        pairCounts[key] = (existing.0, existing.1, existing.2 + 1)
                    } else {
                        pairCounts[key] = (symbols[i], symbols[j], 1)
                    }
                }
            }
        }

        sharedSymbols = pairCounts.values
            .filter { $0.2 >= 2 }
            .sorted { $0.2 > $1.2 }
            .prefix(8)
            .map { symbol1, symbol2, count in
                SymbolPair(symbol1: symbol1, symbol2: symbol2, coOccurrenceCount: count)
            }
    }
}

#Preview {
    RecurringDreamAnalysisView()
}
