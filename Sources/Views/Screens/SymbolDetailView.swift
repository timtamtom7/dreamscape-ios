import SwiftUI

// MARK: - StatBadge (shared component)
struct StatBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct SymbolDetailView: View {
    let symbol: Symbol

    @EnvironmentObject var symbolsViewModel: SymbolsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection

                        // R2: Rarity badge
                        raritySection

                        // R2: Emotional tag
                        if let emotionalTag = symbol.emotionalTag {
                            emotionalTagSection(emotionalTag)
                        }

                        // R2: Symbol Cluster
                        if let clusterName = symbol.clusterName(for: symbolsViewModel.symbols) {
                            clusterSection(clusterName)
                        }

                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        // Timeline
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Occurrence Timeline")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            SymbolDiaryTimeline(
                                frequency: symbol.frequency,
                                lastSeen: symbol.lastSeen,
                                diaryEntries: symbolsViewModel.symbolDiaryEntries(for: symbol.id)
                            )
                        }

                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        // Dreams containing this symbol
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Dreams (\(symbolsViewModel.dreamsForSymbol.count))")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Spacer()

                                Button(action: { showShareSheet = true }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(AppColors.auroraCyan)
                                        .font(.body)
                                }
                            }

                            if symbolsViewModel.dreamsForSymbol.isEmpty {
                                Text("No dreams found")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                ForEach(symbolsViewModel.dreamsForSymbol) { dream in
                                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                                        DreamCard(dream: dream)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Spacer(minLength: 50)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.auroraCyan)
                }
            }
            .onAppear {
                symbolsViewModel.loadDreamsForSymbol(symbol)
            }
            .sheet(isPresented: $showShareSheet) {
                SymbolInsightShareView(symbol: symbol, dreams: symbolsViewModel.dreamsForSymbol)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(symbol.category.color.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: symbol.category.icon)
                        .font(.title2)
                        .foregroundColor(symbol.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.name)
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    Text(symbol.category.displayName)
                        .font(AppFonts.caption)
                        .foregroundColor(symbol.category.color)
                }

                Spacer()
            }

            HStack(spacing: 24) {
                StatBadge(
                    title: "Appearances",
                    value: "\(symbol.frequency)"
                )

                StatBadge(
                    title: "Last Seen",
                    value: symbol.lastSeen.relativeFormatted()
                )
            }
        }
    }

    private var raritySection: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol.rarityLevel.icon)
                .font(.caption)
            Text(symbol.rarityLevel.rawValue)
                .font(AppFonts.callout)
            Text("rarity")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .foregroundColor(symbol.rarityLevel.color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(symbol.rarityLevel.color.opacity(0.15))
        .cornerRadius(999)
    }

    private func emotionalTagSection(_ tag: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emotional Quality")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)

            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.nebulaPink)
                Text(tag)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.nebulaPink.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private func clusterSection(_ clusterName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Symbol Cluster: \(clusterName)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("This symbol frequently appears with related symbols in your dreams, forming a \(clusterName.lowercased()) theme.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.auroraCyan.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Symbol Diary Timeline

struct SymbolDiaryTimeline: View {
    let frequency: Int
    let lastSeen: Date
    let diaryEntries: [SymbolDiaryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Bar chart style timeline
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 3) {
                    ForEach(0..<monthsInView, id: \.self) { monthIndex in
                        let monthDate = calendar.date(byAdding: .month, value: -monthIndex, to: Date())!
                        let count = countForMonth(monthDate)
                        let maxCount = maxOccurrencesInAnyMonth

                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    count > 0 ? AppColors.auroraCyan : AppColors.surface
                                )
                                .frame(height: max(8, CGFloat(count) / CGFloat(max(maxCount, 1)) * (geometry.size.height - 16)))

                            Text(monthAbbreviation(monthDate))
                                .font(.system(size: 8))
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                }
                .frame(height: geometry.size.height)
            }
            .frame(height: 80)
            .padding(.vertical, 8)

            // Occurrence summary
            HStack {
                Circle()
                    .fill(AppColors.auroraCyan)
                    .frame(width: 6, height: 6)
                Text("\(frequency) total occurrence\(frequency == 1 ? "" : "s")")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("Last: \(lastSeen.relativeFormatted())")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private var monthsInView: Int { 12 }

    private var calendar: Calendar { Calendar.current }

    private var maxOccurrencesInAnyMonth: Int {
        max(1, frequency)
    }

    private func countForMonth(_ date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        return diaryEntries.filter { entry in
            let entryComponents = calendar.dateComponents([.year, .month], from: entry.date)
            return entryComponents.year == components.year && entryComponents.month == components.month
        }.count
    }

    private func monthAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Symbol Insight Share View

struct SymbolInsightShareView: View {
    let symbol: Symbol
    let dreams: [Dream]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        insightCard
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Share Insight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: generateShareText(), subject: Text("Symbol Insight"), message: Text("Shared from Dreamscape")) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
        }
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(symbol.category.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: symbol.category.icon)
                        .foregroundColor(symbol.category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(symbol.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Symbol Insight")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }

                Spacer()

                Image(systemName: "moon.stars.fill")
                    .foregroundColor(AppColors.nebulaPink)
            }

            if let emotionalTag = symbol.emotionalTag {
                Text("When I dream of **\(symbol.name)**, it often feels like **\(emotionalTag.lowercased())**.")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("I've been dreaming about **\(symbol.name)** for **\(dreams.count)** dream\(dreams.count == 1 ? "" : "s") now — it's become a \(symbol.rarityLevel.rawValue.lowercased()) presence in my subconscious.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                Spacer()
                Text("Shared via Dreamscape ✦")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
                Spacer()
            }
        }
        .padding(20)
        .background(AppColors.surface)
        .cornerRadius(20)
    }

    private func generateShareText() -> String {
        var text = "🔮 Symbol Insight: **\(symbol.name)**\n\n"
        if let emotionalTag = symbol.emotionalTag {
            text += "When I dream of \(symbol.name), it feels like \(emotionalTag.lowercased()).\n\n"
        }
        text += "I've been dreaming about \(symbol.name) for \(dreams.count) dreams now."
        text += "\n\nShared via Dreamscape ✦"
        return text
    }
}

#Preview {
    SymbolDetailView(symbol: Symbol.samples[0])
        .environmentObject(SymbolsViewModel())
}
