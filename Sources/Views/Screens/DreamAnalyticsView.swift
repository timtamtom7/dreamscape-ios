import SwiftUI

struct DreamAnalyticsView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var selectedTimeRange: TimeRange = .allTime

    enum TimeRange: String, CaseIterable {
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case allTime = "All Time"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Time range picker
                        timeRangePicker

                        // Dream frequency
                        dreamFrequencySection

                        // Emotion trends
                        emotionTrendsSection

                        // Symbol frequency
                        symbolFrequencySection

                        // Dream prediction
                        dreamPredictionSection

                        // Dream evolution
                        dreamEvolutionSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Dream Analytics")
        }
    }

    private var timeRangePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button {
                        selectedTimeRange = range
                    } label: {
                        Text(range.rawValue)
                            .font(AppFonts.caption)
                            .foregroundColor(selectedTimeRange == range ? AppColors.backgroundPrimary : AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTimeRange == range ? AppColors.auroraCyan : AppColors.surface)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    private var filteredDreams: [Dream] {
        let cutoff = cutoffDate(for: selectedTimeRange)
        if cutoff == nil {
            return journalViewModel.dreams
        }
        return journalViewModel.dreams.filter { $0.createdAt >= cutoff! }
    }

    private var dreamFrequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Dream Frequency")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            // Frequency stats
            HStack(spacing: 16) {
                frequencyStat(value: "\(filteredDreams.count)", label: "Total", color: AppColors.auroraCyan)
                frequencyStat(value: "\(monthlyAverage)", label: "Monthly Avg", color: AppColors.nebulaPink)
                frequencyStat(value: "\(lucidCount)", label: "Lucid", color: AppColors.starGold)
            }

            // Simple bar chart
            monthlyBarChart
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func frequencyStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.titleSmall)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var monthlyBarChart: some View {
        let monthlyData = getMonthlyData()
        let maxValue = monthlyData.map { $0.count }.max() ?? 1

        return HStack(alignment: .bottom, spacing: 4) {
            ForEach(monthlyData, id: \.month) { data in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.auroraCyan)
                        .frame(height: CGFloat(data.count) / CGFloat(maxValue) * 80)

                    Text(data.month)
                        .font(.system(size: 8))
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .frame(height: 110)
    }

    private var emotionTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Emotion Trends")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            let emotionData = getEmotionData()

            if emotionData.isEmpty {
                Text("Record more dreams to see emotion trends")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textMuted)
                    .italic()
            } else {
                ForEach(emotionData.prefix(5), id: \.emotion) { data in
                    emotionBar(emotion: data.emotion, count: data.count, max: emotionData.first?.count ?? 1)
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func emotionBar(emotion: String, count: Int, max: Int) -> some View {
        HStack(spacing: 8) {
            Text(emotion)
                .font(AppFonts.callout)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.surfaceElevated)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.nebulaPink)
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(max))
                }
            }
            .frame(height: 20)

            Text("\(count)")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
        }
    }

    private var symbolFrequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Top Symbols")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            let symbolData = getSymbolData()

            if symbolData.isEmpty {
                Text("Record more dreams to see symbol patterns")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textMuted)
                    .italic()
            } else {
                ForEach(symbolData.prefix(5), id: \.symbol.name) { data in
                    symbolRow(symbol: data.symbol.name, count: data.count, max: symbolData.first?.count ?? 1, category: data.symbol.category)
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func symbolRow(symbol: String, count: Int, max: Int, category: SymbolCategory) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(symbolCategoryColor(category))
                .frame(width: 8, height: 8)

            Text(symbol)
                .font(AppFonts.callout)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.surfaceElevated)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(symbolCategoryColor(category).opacity(0.7))
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(max))
                }
            }
            .frame(height: 16)

            Text("\(count)")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
        }
    }

    private func symbolCategoryColor(_ category: SymbolCategory) -> Color {
        switch category {
        case .person: return .purple
        case .place: return .blue
        case .object: return .orange
        case .emotion: return .cyan
        }
    }

    private var dreamPredictionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.starGold)
                Text("Dream Insights")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            VStack(alignment: .leading, spacing: 12) {
                insightCard(icon: "bolt.fill", text: generatePrediction(), color: AppColors.warning)
                insightCard(icon: "moon.fill", text: generateSleepInsight(), color: AppColors.nebulaPink)
                insightCard(icon: "arrow.triangle.2.circlepath", text: generatePatternInsight(), color: AppColors.auroraCyan)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func insightCard(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(AppFonts.callout)
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    private var dreamEvolutionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(AppColors.success)
                Text("Dream Evolution")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            let firstDreams = Array(journalViewModel.dreams.sorted { $0.createdAt < $1.createdAt }.prefix(3))
            let recentDreams = Array(journalViewModel.dreams.sorted { $0.createdAt > $1.createdAt }.prefix(3))

            if !firstDreams.isEmpty && !recentDreams.isEmpty {
                HStack(spacing: 16) {
                    evolutionColumn(title: "First Dreams", dreams: firstDreams)
                    Image(systemName: "arrow.right")
                        .foregroundColor(AppColors.textMuted)
                    evolutionColumn(title: "Recent Dreams", dreams: recentDreams)
                }
            } else {
                Text("Record more dreams to see how your dreaming has evolved")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textMuted)
                    .italic()
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func evolutionColumn(title: String, dreams: [Dream]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            ForEach(dreams) { dream in
                Text(dream.shortFormattedDate)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.auroraCyan)
                Text(dream.summary.isEmpty ? dream.content.prefix(40) + "..." : dream.summary.prefix(40) + "...")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Data Helpers

    private var monthlyAverage: Int {
        let months = getMonthlyData()
        guard !months.isEmpty else { return 0 }
        let total = months.reduce(0) { $0 + $1.count }
        return total / months.count
    }

    private var lucidCount: Int {
        filteredDreams.filter { $0.isLucid }.count
    }

    private func cutoffDate(for range: TimeRange) -> Date? {
        let calendar = Calendar.current
        switch range {
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: Date())
        case .quarter:
            return calendar.date(byAdding: .month, value: -3, to: Date())
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: Date())
        case .allTime:
            return nil
        }
    }

    private func getMonthlyData() -> [(month: String, count: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var monthlyMap: [String: Int] = [:]

        for dream in filteredDreams {
            let month = formatter.string(from: dream.createdAt)
            monthlyMap[month, default: 0] += 1
        }

        return monthlyMap.map { (month: $0.key, count: $0.value) }
            .sorted { $0.month < $1.month }
    }

    private func getEmotionData() -> [(emotion: String, count: Int)] {
        var emotionCounts: [String: Int] = [:]
        for dream in filteredDreams {
            for emotion in dream.emotionalTags {
                emotionCounts[emotion, default: 0] += 1
            }
        }
        return emotionCounts.map { (emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private func getSymbolData() -> [(symbol: Symbol, count: Int)] {
        var symbolCounts: [String: (symbol: Symbol, count: Int)] = [:]
        for dream in filteredDreams {
            for symbol in dream.symbols {
                if let existing = symbolCounts[symbol.name] {
                    symbolCounts[symbol.name] = (symbol: existing.symbol, count: existing.count + 1)
                } else {
                    symbolCounts[symbol.name] = (symbol: symbol, count: 1)
                }
            }
        }
        return symbolCounts.values.sorted { $0.count > $1.count }
    }

    private func generatePrediction() -> String {
        let dreams = filteredDreams
        let anxiousCount = dreams.filter { $0.emotionalTags.contains { $0.lowercased().contains("fear") || $0.lowercased().contains("anxiety") } }.count
        let total = dreams.count

        if total == 0 {
            return "Record more dreams to receive personalized insights about your dream patterns."
        }

        let anxiousRatio = Double(anxiousCount) / Double(total)
        if anxiousRatio > 0.4 {
            return "You tend to experience more anxiety-driven dreams before significant life decisions or stressful periods."
        } else if anxiousRatio < 0.1 && total > 5 {
            return "Your dreams are predominantly peaceful. This often reflects emotional equilibrium in your waking life."
        }

        return "Your dream patterns suggest a balanced subconscious life. No strong anxiety correlations detected."
    }

    private func generateSleepInsight() -> String {
        guard let first = journalViewModel.dreams.min(by: { $0.createdAt < $1.createdAt }),
              let last = journalViewModel.dreams.max(by: { $0.createdAt < $1.createdAt }) else {
            return "Record dreams consistently to track your sleep patterns."
        }

        let daysBetween = Calendar.current.dateComponents([.day], from: first.createdAt, to: last.createdAt).day ?? 1
        let dreamRate = Double(journalViewModel.dreams.count) / Double(max(1, daysBetween))

        if dreamRate > 0.8 {
            return "You dream frequently — about \(String(format: "%.1f", dreamRate)) dream\(dreamRate == 1 ? "" : "s") per night on average."
        } else {
            return "You dream less frequently, but your dreams tend to be vivid and memorable when you do."
        }
    }

    private func generatePatternInsight() -> String {
        let dreams = filteredDreams
        let recurringCount = dreams.filter { $0.recurringVariantId != nil }.count

        if recurringCount > 2 {
            return "You have \(recurringCount) recurring dream patterns. These often point to unresolved themes your mind returns to repeatedly."
        }

        let allSymbols = dreams.flatMap { $0.symbols }
        let waterSymbols = allSymbols.filter { $0.name.lowercased().contains("water") }
        if waterSymbols.count > 3 {
            return "Water appears frequently in your dreams. This often symbolizes emotional depth or the unconscious mind."
        }

        return "Your dreams show diverse themes with no strong recurring patterns yet. This variety is healthy and normal."
    }
}
