import SwiftUI

struct DreamDetailView: View {
    let dream: Dream

    @EnvironmentObject var journalViewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dream.formattedDate)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.auroraCyan)

                        Text("Dream Summary")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text(dream.summary.isEmpty ? "No summary available" : dream.summary)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Divider()
                        .background(AppColors.textMuted.opacity(0.3))

                    // Dream content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dream")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text(dream.content)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineSpacing(6)
                    }

                    // Detected symbols
                    if !dream.symbols.isEmpty {
                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Detected Symbols")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            SymbolChipRow(symbols: dream.symbols)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(24)
            }
        }
        .navigationTitle("Dream")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(AppColors.error)
                }
            }
        }
        .alert("Delete Dream?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                journalViewModel.deleteDream(dream)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This dream will be permanently deleted.")
        }
    }
}

#Preview {
    NavigationStack {
        DreamDetailView(dream: .sample)
            .environmentObject(JournalViewModel())
    }
}
