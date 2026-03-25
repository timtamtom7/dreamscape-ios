import SwiftUI

struct LegacyArchiveView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var searchText = ""
    @State private var selectedYear: Int?
    @State private var showingExport = false
    @State private var showingMemorialMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Stats overview
                        statsOverview

                        // Annual Dream Review
                        annualReviewSection

                        // Year filter
                        yearFilterSection

                        // Search
                        searchSection

                        // Dream archive
                        dreamArchiveSection

                        // Memorial mode
                        memorialModeSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Dream Legacy")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingExport = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                LegacyExportView()
            }
        }
    }

    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Dream Journey")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 16) {
                StatCardLegacy(value: "\(journalViewModel.dreams.count)", label: "Total Dreams", icon: "moon.stars.fill", color: AppColors.nebulaPink)
                StatCardLegacy(value: "\(uniqueSymbolsCount)", label: "Symbols", icon: "star.fill", color: AppColors.starGold)
                StatCardLegacy(value: yearString, label: "Dreaming Since", icon: "calendar", color: AppColors.auroraCyan)
            }
        }
    }

    private var annualReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Annual Dream Review")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                if let year = currentYearDreams.isEmpty ? nil : Calendar.current.component(.year, from: Date()) {
                    Text("\(year) in Dreams")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    Text(generateAnnualSummary(for: year))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(4)
                } else {
                    Text("Record dreams to generate your annual review")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textMuted)
                        .italic()
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(16)
        }
    }

    private var yearFilterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Year")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    yearChip(year: nil, label: "All")

                    ForEach(availableYears, id: \.self) { year in
                        yearChip(year: year, label: "\(year)")
                    }
                }
            }
        }
    }

    private func yearChip(year: Int?, label: String) -> some View {
        Button {
            selectedYear = year
        } label: {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(selectedYear == year ? AppColors.backgroundPrimary : AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedYear == year ? AppColors.auroraCyan : AppColors.surface)
                .cornerRadius(12)
        }
    }

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            TextField("Search your dream archive...", text: $searchText)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private var dreamArchiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dream Archive")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            if filteredDreams.isEmpty {
                Text("No dreams found")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textMuted)
                    .italic()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(filteredDreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        ArchiveDreamRow(dream: dream)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var memorialModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memorial Mode")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Create a shareable legacy document of your dream life — distillable to those you trust.")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)

                Button {
                    showingMemorialMode = true
                } label: {
                    Label("Create Memorial Document", systemImage: "heart.fill")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.nebulaPink)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(16)
        }
    }

    private var filteredDreams: [Dream] {
        var dreams = journalViewModel.dreams

        if let year = selectedYear {
            dreams = dreams.filter { Calendar.current.component(.year, from: $0.createdAt) == year }
        }

        if !searchText.isEmpty {
            dreams = dreams.filter {
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.summary.localizedCaseInsensitiveContains(searchText) ||
                $0.symbols.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return dreams.sorted { $0.createdAt > $1.createdAt }
    }

    private var availableYears: [Int] {
        let years = Set(journalViewModel.dreams.map { Calendar.current.component(.year, from: $0.createdAt) })
        return Array(years).sorted(by: >)
    }

    private var uniqueSymbolsCount: Int {
        Set(journalViewModel.dreams.flatMap { $0.symbols.map { $0.name } }).count
    }

    private var yearString: String {
        guard let first = journalViewModel.dreams.min(by: { $0.createdAt < $1.createdAt }) else {
            return "Now"
        }
        let years = Calendar.current.dateComponents([.year], from: first.createdAt, to: Date()).year ?? 0
        if years == 0 { return "This year" }
        return "\(years)y"
    }

    private var currentYearDreams: [Dream] {
        let year = Calendar.current.component(.year, from: Date())
        return journalViewModel.dreams.filter { Calendar.current.component(.year, from: $0.createdAt) == year }
    }

    private func generateAnnualSummary(for year: Int) -> String {
        let yearDreams = journalViewModel.dreams.filter { Calendar.current.component(.year, from: $0.createdAt) == year }
        guard !yearDreams.isEmpty else { return "No dreams recorded this year." }

        let totalDreams = yearDreams.count
        let lucidDreams = yearDreams.filter { $0.isLucid }.count
        let recurring = yearDreams.filter { $0.recurringVariantId != nil }.count
        let allSymbols = yearDreams.flatMap { $0.symbols }
        let symbolCounts = Dictionary(grouping: allSymbols, by: { $0.name }).mapValues { $0.count }
        let topSymbols = symbolCounts.sorted { $0.value > $1.value }.prefix(3)
        let topSymbolNames = topSymbols.map { $0.key }.joined(separator: ", ")
        let emotions = yearDreams.flatMap { $0.emotionalTags }
        let emotionCounts = Dictionary(grouping: emotions, by: { $0 }).mapValues { $0.count }
        let topEmotion = emotionCounts.max { $0.value < $1.value }?.key ?? "varied"

        return "This year you recorded \(totalDreams) dream\(totalDreams == 1 ? "" : "s"). \(lucidDreams) were lucid, and \(recurring) showed recurring patterns. Your subconscious frequently surfaced themes around \(topSymbolNames.isEmpty ? "various symbols" : topSymbolNames). Your dominant emotional tone was \(topEmotion.lowercased())."
    }
}

struct StatCardLegacy: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct ArchiveDreamRow: View {
    let dream: Dream

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dream.shortFormattedDate)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.auroraCyan)

                Text(dream.summary.isEmpty ? dream.content.prefix(60) + "..." : dream.summary)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 8) {
                if dream.isLucid {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.nebulaPink)
                }

                Text("\(dream.symbols.count)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct LegacyExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Export Your Dream Legacy")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Download your complete dream archive as a portable document.")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)

                    VStack(spacing: 12) {
                        exportOption(format: "PDF", icon: "doc.fill")
                        exportOption(format: "JSON", icon: "doc.text.fill")
                        exportOption(format: "Markdown", icon: "doc.plaintext.fill")
                    }

                    Spacer()

                    Button {
                        exportDocument()
                    } label: {
                        Label(isExporting ? "Exporting..." : "Export All Dreams", systemImage: "square.and.arrow.up")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.auroraCyan)
                            .cornerRadius(12)
                    }
                    .disabled(isExporting)
                }
                .padding()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func exportOption(format: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.auroraCyan)
                .frame(width: 24)
            Text("\(format) Document")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private func exportDocument() {
        isExporting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isExporting = false
            dismiss()
        }
    }
}
