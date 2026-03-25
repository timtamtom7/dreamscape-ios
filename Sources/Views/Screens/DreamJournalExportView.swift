import SwiftUI

/// R4: Dream Journal Export View — export options for dream journals
struct DreamJournalExportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ExportViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerCard
                            .padding(.horizontal)

                        // Export options
                        exportOptions
                            .padding(.horizontal)

                        // Year selector (for yearbook)
                        if viewModel.selectedExportType == .annualYearbook {
                            yearPicker
                                .padding(.horizontal)
                        }

                        // Preview info
                        previewCard
                            .padding(.horizontal)

                        // Export button
                        exportButton
                            .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Export Dreams")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                if let url = viewModel.exportedFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Export Complete", isPresented: $viewModel.showingAlert) {
                Button("Share") {
                    viewModel.showingShareSheet = true
                }
                Button("Done") { dismiss() }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext.fill")
                .font(.system(size: 36))
                .foregroundColor(AppColors.nebulaPink)

            Text("Export Your Dreams")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Create beautiful print-ready documents of your dream journey")
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

    private var exportOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Type")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)

            ForEach(ExportType.allCases) { type in
                ExportTypeCard(
                    type: type,
                    isSelected: viewModel.selectedExportType == type,
                    onTap: { viewModel.selectedExportType = type }
                )
            }
        }
    }

    private var yearPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Year")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)

            Picker("Year", selection: $viewModel.selectedYear) {
                ForEach(viewModel.availableYears, id: \.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.auroraCyan)
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(12)
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eye.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Preview")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            HStack(spacing: 16) {
                PreviewStatCard(
                    icon: "doc.text.fill",
                    value: "\(viewModel.dreamCount)",
                    label: "Dreams"
                )

                PreviewStatCard(
                    icon: "calendar",
                    value: "\(viewModel.dateRange)",
                    label: "Date Range"
                )

                PreviewStatCard(
                    icon: "printer.fill",
                    value: viewModel.selectedExportType.pageCount,
                    label: "Pages Est."
                )
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var exportButton: some View {
        Button(action: { viewModel.export() }) {
            HStack {
                if viewModel.isExporting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(AppColors.backgroundPrimary)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(viewModel.isExporting ? "Generating..." : "Generate PDF")
            }
            .font(AppFonts.callout)
            .foregroundColor(AppColors.backgroundPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.auroraCyan)
            .cornerRadius(12)
        }
        .disabled(viewModel.isExporting || viewModel.dreamCount == 0)
        .opacity(viewModel.dreamCount == 0 ? 0.5 : 1)
    }
}

// MARK: - Export Type

enum ExportType: String, CaseIterable, Identifiable {
    case fullJournal = "full_journal"
    case annualYearbook = "annual_yearbook"
    case timeline = "timeline"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullJournal: return "Full Dream Journal"
        case .annualYearbook: return "Annual Yearbook"
        case .timeline: return "Dream Timeline"
        }
    }

    var description: String {
        switch self {
        case .fullJournal: return "Complete PDF book with all dreams, summaries, and symbols"
        case .annualYearbook: return "Year in review — highlights, top symbols, monthly stats"
        case .timeline: return "Visual timeline of your dream journey"
        }
    }

    var icon: String {
        switch self {
        case .fullJournal: return "book.fill"
        case .annualYearbook: return "star.fill"
        case .timeline: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .fullJournal: return AppColors.auroraCyan
        case .annualYearbook: return AppColors.starGold
        case .timeline: return AppColors.nebulaPink
        }
    }

    var pageCount: String {
        switch self {
        case .fullJournal: return "~"
        case .annualYearbook: return "2"
        case .timeline: return "1"
        }
    }
}

// MARK: - Export Type Card

struct ExportTypeCard: View {
    let type: ExportType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? type.color : AppColors.textSecondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(type.description)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(type.color)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? type.color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview Stat Card

struct PreviewStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppColors.auroraCyan)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - View Model

@MainActor
final class ExportViewModel: ObservableObject {
    @Published var selectedExportType: ExportType = .fullJournal
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var availableYears: [Int] = []
    @Published var dreamCount: Int = 0
    @Published var dateRange: String = "-"
    @Published var isExporting = false
    @Published var showingShareSheet = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var exportedFileURL: URL?

    private let databaseService = DatabaseService.shared
    private let pdfService = PDFExportService.shared

    func loadData() {
        do {
            let dreams = try databaseService.fetchAllDreams()
            dreamCount = dreams.count

            if !dreams.isEmpty {
                let sorted = dreams.sorted { $0.createdAt < $1.createdAt }
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                dateRange = "\(formatter.string(from: sorted.first!.createdAt)) - \(formatter.string(from: sorted.last!.createdAt))"

                let years = Set(dreams.map { Calendar.current.component(.year, from: $0.createdAt) })
                availableYears = years.sorted(by: >)
                if !availableYears.contains(selectedYear) {
                    selectedYear = availableYears.first ?? Calendar.current.component(.year, from: Date())
                }
            }
        } catch {
            print("Load error: \(error)")
        }
    }

    func export() {
        isExporting = true

        Task {
            do {
                let dreams = try databaseService.fetchAllDreams()

                var pdfData: Data?
                var fileName: String

                switch selectedExportType {
                case .fullJournal:
                    pdfData = pdfService.generateDreamJournalPDF(dreams: dreams)
                    fileName = "Dreamscape_Journal_\(formattedDate()).pdf"
                case .annualYearbook:
                    let yearDreams = dreams.filter { Calendar.current.component(.year, from: $0.createdAt) == selectedYear }
                    pdfData = pdfService.generateYearbookPDF(dreams: dreams, year: selectedYear)
                    fileName = "Dreamscape_\(selectedYear)_Yearbook.pdf"
                case .timeline:
                    pdfData = pdfService.generateTimelinePDF(dreams: dreams)
                    fileName = "Dreamscape_Timeline_\(formattedDate()).pdf"
                }

                if let data = pdfData {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                    try data.write(to: tempURL)
                    exportedFileURL = tempURL
                    alertMessage = "Your \(selectedExportType.displayName) has been created and is ready to share."
                    showingAlert = true
                } else {
                    alertMessage = "Failed to generate PDF. Please try again."
                    showingAlert = true
                }
            } catch {
                alertMessage = "Export failed: \(error.localizedDescription)"
                showingAlert = true
            }

            isExporting = false
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    DreamJournalExportView()
}
