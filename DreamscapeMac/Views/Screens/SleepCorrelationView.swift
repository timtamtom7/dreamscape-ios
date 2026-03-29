import SwiftUI

struct SleepCorrelationView: View {
    @State private var insights: [SleepInsight] = []
    @State private var correlations: [SleepCorrelation] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 12) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.nsAccentPrimary)

                        Text("Sleep & Dream Correlation")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Discover how your sleep patterns affect your dreams")
                            .font(.subheadline)
                            .foregroundStyle(Color.nsTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        LinearGradient(
                            colors: [Color.nsSurface, Color.nsSurface.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickStatCard(
                            title: "Avg Sleep",
                            value: averageSleepDuration,
                            unit: "hrs",
                            icon: "bed.double.fill",
                            color: Color(hex: "5EEAD4")
                        )

                        QuickStatCard(
                            title: "Avg Deep Sleep",
                            value: String(format: "%.0f", averageDeepSleep),
                            unit: "%",
                            icon: "waveform.path.ecg",
                            color: Color(hex: "C084FC")
                        )

                        QuickStatCard(
                            title: "Best Sleep",
                            value: bestSleepQuality,
                            unit: "",
                            icon: "star.fill",
                            color: Color(hex: "FCD34D")
                        )

                        QuickStatCard(
                            title: "Recording Days",
                            value: "\(correlations.count)",
                            unit: "",
                            icon: "calendar",
                            color: Color(hex: "34D399")
                        )
                    }
                    .padding(.horizontal)

                    // Insights Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insights")
                            .font(.headline)
                            .foregroundStyle(Color.nsTextPrimary)
                            .padding(.horizontal)

                        if insights.isEmpty {
                            ContentUnavailableView(
                                "Not Enough Data",
                                systemImage: "chart.line.uptrend.xyaxis",
                                description: Text("Record more sleep data to see correlations")
                            )
                            .padding()
                        } else {
                            ForEach(insights) { insight in
                                InsightCard(insight: insight)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Recent Correlations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sleep Records")
                            .font(.headline)
                            .foregroundStyle(Color.nsTextPrimary)
                            .padding(.horizontal)

                        ForEach(correlations.prefix(7)) { correlation in
                            CorrelationRow(correlation: correlation)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.nsBackground)
            .navigationTitle("Sleep Correlation")
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }

    private var averageSleepDuration: String {
        guard !correlations.isEmpty else { return "--" }
        let avg = correlations.map { $0.sleepDuration }.reduce(0, +) / Double(correlations.count) / 3600
        return String(format: "%.1f", avg)
    }

    private var averageDeepSleep: Double {
        guard !correlations.isEmpty else { return 0 }
        return correlations.map { $0.deepSleepPercent }.reduce(0, +) / Double(correlations.count)
    }

    private var bestSleepQuality: String {
        correlations.max(by: { $0.sleepQuality.hashValue < $1.sleepQuality.hashValue })?.sleepQuality.rawValue ?? "--"
    }

    private func loadData() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 200_000_000)

        correlations = DreamSharingService.shared.getSleepCorrelations(limit: 30)
        insights = DreamSharingService.shared.generateSleepInsights()

        isLoading = false
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)

                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.nsTextPrimary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(Color.nsTextSecondary)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.nsTextSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: SleepInsight

    var typeColor: Color {
        Color(hex: insight.insightType.color)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.insightType.icon)
                .font(.title3)
                .foregroundStyle(typeColor)
                .frame(width: 32, height: 32)
                .background(typeColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.nsTextPrimary)

                    Spacer()

                    Text("\(Int(insight.confidence * 100))% confidence")
                        .font(.caption2)
                        .foregroundStyle(Color.nsTextMuted)
                }

                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(Color.nsTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !insight.relevantSymbols.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(insight.relevantSymbols.prefix(3), id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption2)
                                .foregroundStyle(Color.nsAccentPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.nsAccentPrimary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Correlation Row

struct CorrelationRow: View {
    let correlation: SleepCorrelation

    var qualityColor: Color {
        Color(hex: correlation.sleepQuality.color)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack {
                Text(correlation.date.formatted(.dateTime.day()))
                    .font(.title3)
                    .fontWeight(.bold)

                Text(correlation.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(Color.nsTextSecondary)
            }
            .frame(width: 44)
            .foregroundStyle(Color.nsTextPrimary)

            // Sleep Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Label(correlation.sleepQuality.rawValue, systemImage: "moon.fill")
                        .font(.caption)
                        .foregroundStyle(qualityColor)

                    Text(formatDuration(correlation.sleepDuration))
                        .font(.caption)
                        .foregroundStyle(Color.nsTextSecondary)
                }

                // Sleep stages bar
                HStack(spacing: 2) {
                    if correlation.deepSleepPercent > 0 {
                        Rectangle()
                            .fill(Color.nsAccentSecondary)
                            .frame(width: CGFloat(correlation.deepSleepPercent) * 1.5, height: 4)
                    }

                    if correlation.remPercent > 0 {
                        Rectangle()
                            .fill(Color.nsAccentPrimary)
                            .frame(width: CGFloat(correlation.remPercent) * 1.5, height: 4)
                    }
                }
                .clipShape(Capsule())
            }

            Spacer()

            // Dream symbols
            HStack(spacing: 4) {
                ForEach(correlation.dreamSymbols.prefix(2), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(Color.nsTextSecondary)
                        .lineLimit(1)
                }

                if correlation.dreamSymbols.count > 2 {
                    Text("+\(correlation.dreamSymbols.count - 2)")
                        .font(.caption2)
                        .foregroundStyle(Color.nsTextMuted)
                }
            }
            .frame(maxWidth: 80)

            // Nightmare indicator
            if correlation.hadNightmare {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "F87171"))
            }
        }
        .padding()
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Share Dream Sheet

struct ShareDreamSheet: View {
    let dream: Dream
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDestination: ShareDestination = .anonymousPool
    @State private var isAnonymous = true
    @State private var communityTag = ""
    @State private var isSharing = false
    @State private var sharedSuccessfully = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Dream Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text(dream.title)
                        .font(.headline)
                        .foregroundStyle(Color.nsTextPrimary)

                    Text(dream.narrative)
                        .font(.caption)
                        .foregroundStyle(Color.nsTextSecondary)
                        .lineLimit(3)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.nsSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Share Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share to")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.nsTextSecondary)

                    ForEach(ShareDestination.allCases, id: \.self) { destination in
                        DestinationRow(
                            destination: destination,
                            isSelected: selectedDestination == destination
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDestination = destination
                            }
                        }
                    }
                }

                Divider()

                // Anonymity Toggle
                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Share Anonymously")
                            .font(.subheadline)
                            .foregroundStyle(Color.nsTextPrimary)

                        Text("Your identity will not be revealed")
                            .font(.caption)
                            .foregroundStyle(Color.nsTextSecondary)
                    }
                }
                .toggleStyle(.switch)
                .tint(Color.nsAccentPrimary)

                // Community Tag
                if selectedDestination != .anonymousPool {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community Tag (optional)")
                            .font(.subheadline)
                            .foregroundStyle(Color.nsTextSecondary)

                        TextField("e.g., flying-dreams, recurring", text: $communityTag)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Spacer()

                // Share Button
                Button {
                    shareDream()
                } label: {
                    if isSharing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else if sharedSuccessfully {
                        Label("Shared!", systemImage: "checkmark")
                    } else {
                        Label("Share Dream", systemImage: "square.and.arrow.up")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(sharedSuccessfully ? Color(hex: "34D399") : Color.nsAccentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isSharing || sharedSuccessfully)
            }
            .padding()
            .background(Color.nsBackground)
            .navigationTitle("Share Dream")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func shareDream() {
        isSharing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            _ = DreamSharingService.shared.shareDream(
                dream,
                anonymously: isAnonymous,
                to: selectedDestination,
                communityTag: communityTag.isEmpty ? nil : communityTag
            )
            isSharing = false
            sharedSuccessfully = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
}

// MARK: - Destination Row

struct DestinationRow: View {
    let destination: ShareDestination
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: destination.icon)
                .font(.title3)
                .foregroundStyle(isSelected ? Color.nsAccentPrimary : Color.nsTextSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(Color.nsTextPrimary)

                Text(destination.description)
                    .font(.caption2)
                    .foregroundStyle(Color.nsTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.nsAccentPrimary)
            }
        }
        .padding()
        .background(isSelected ? Color.nsAccentPrimary.opacity(0.1) : Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
