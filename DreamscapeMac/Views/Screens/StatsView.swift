import SwiftUI

struct StatsView: View {
    @Bindable var store: DreamStore

    var body: some View {
        ZStack {
            StarFieldView()

            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    statsCardsGrid
                    luciditySection
                    topSymbolsSection
                    moodDistributionSection
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .font(.title2)
                .foregroundColor(Theme.auroraCyan)
            Text("Dream Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            Spacer()
        }
    }

    private var statsCardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Total Dreams",
                value: "\(store.dreams.count)",
                icon: "moon.stars.fill",
                color: Theme.nebulaPink
            )

            StatCard(
                title: "Current Streak",
                value: "\(store.streak) days",
                icon: "flame.fill",
                color: Theme.amberGlow
            )

            StatCard(
                title: "Lucid Dreams",
                value: "\(store.lucidDreamCount)",
                icon: "sparkles",
                color: Theme.auroraCyan
            )

            StatCard(
                title: "This Week",
                value: "\(store.dreamsThisWeek)",
                icon: "calendar",
                color: Theme.dreamGreen
            )
        }
    }

    private var luciditySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lucidity Overview")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)

            VStack(spacing: 8) {
                HStack {
                    Text("Fully Lucid (Level 5)")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    let count = store.dreams.filter { $0.lucidityLevel == 5 }.count
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.auroraCyan)
                }

                LucidityBar(dreams: store.dreams)

                HStack {
                    Text("Average Lucidity")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    let avg = store.dreams.isEmpty ? 0 : Double(store.dreams.reduce(0) { $0 + $1.lucidityLevel }) / Double(store.dreams.count)
                    Text(String(format: "%.1f", avg))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.auroraCyan)
                }
            }
            .padding(16)
            .background(Theme.cardBg)
            .cornerRadius(16)
        }
    }

    private var topSymbolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Common Symbols")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)

            VStack(spacing: 8) {
                ForEach(store.topSymbols(limit: 5)) { symbol in
                    SymbolStatRow(symbol: symbol, maxCount: store.topSymbols(limit: 1).first?.occurrenceCount ?? 1)
                }
            }
            .padding(16)
            .background(Theme.cardBg)
            .cornerRadius(16)
        }
    }

    private var moodDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Distribution")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)

            VStack(spacing: 8) {
                ForEach(Dream.Mood.allCases.prefix(5)) { mood in
                    let count = store.dreamsByMood(mood).count
                    let percentage = store.dreams.isEmpty ? 0 : Double(count) / Double(store.dreams.count)

                    HStack {
                        Text(mood.emoji)
                            .font(.caption)
                        Text(mood.rawValue)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: mood.color))
                    }

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: mood.color).opacity(0.3))
                            .frame(width: geometry.size.width * percentage, height: 6)
                    }
                    .frame(height: 6)
                }
            }
            .padding(16)
            .background(Theme.cardBg)
            .cornerRadius(16)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(16)
    }
}

struct LucidityBar: View {
    let dreams: [Dream]

    private var distribution: [Int] {
        var counts = [0, 0, 0, 0, 0]
        for dream in dreams {
            if dream.lucidityLevel >= 1 && dream.lucidityLevel <= 5 {
                counts[dream.lucidityLevel - 1] += 1
            }
        }
        return counts
    }

    private var maxCount: Int {
        distribution.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(1...5, id: \.self) { level in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.auroraCyan)
                        .frame(width: 24, height: maxCount > 0 ? CGFloat(distribution[level - 1]) / CGFloat(maxCount) * 60 : 0)

                    Text("\(level)")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .frame(height: 80, alignment: .bottom)
    }
}

struct SymbolStatRow: View {
    let symbol: DreamSymbol
    let maxCount: Int

    private var percentage: Double {
        maxCount > 0 ? Double(symbol.occurrenceCount) / Double(maxCount) : 0
    }

    var body: some View {
        HStack {
            Image(systemName: symbol.category.icon)
                .font(.caption)
                .foregroundColor(Color(hex: symbol.category.color))
                .frame(width: 20)

            Text(symbol.name.capitalized)
                .font(.caption)
                .foregroundColor(Theme.textPrimary)

            Spacer()

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: symbol.category.color).opacity(0.3))
                    .frame(width: geometry.size.width * percentage, height: 8)
            }
            .frame(width: 60, height: 8)

            Text("\(symbol.occurrenceCount)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.textSecondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}
