import SwiftUI

struct DreamDetailView: View {
    let dream: Dream

    @EnvironmentObject var journalViewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false

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

                    // R2: Mood & Lucid Tags
                    if dream.mood != nil || dream.isLucid {
                        tagsRow
                    }

                    // R2: Recurring Dream Indicator
                    if let recurringId = dream.recurringVariantId {
                        recurringBadge(count: dream.recurringCount(in: journalViewModel.dreams))
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

                    // R2: Attached Photo
                    if dream.attachedPhotoURL != nil {
                        photoSection
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

                    // R2: Emotional Tags
                    if !dream.emotionalTags.isEmpty {
                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emotional Tags")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            FlowLayout(spacing: 8) {
                                ForEach(dream.emotionalTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(AppFonts.callout)
                                        .foregroundColor(AppColors.nebulaPink)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppColors.nebulaPink.opacity(0.15))
                                        .cornerRadius(999)
                                }
                            }
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

            ToolbarItem(placement: .primaryAction) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.auroraCyan)
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
        .sheet(isPresented: $showShareSheet) {
            DreamShareCardView(dream: dream)
        }
    }

    // MARK: - Subviews

    private var tagsRow: some View {
        HStack(spacing: 10) {
            if let mood = dream.mood {
                HStack(spacing: 6) {
                    Image(systemName: mood.icon)
                        .font(.caption)
                    Text(mood.displayName)
                        .font(AppFonts.callout)
                }
                .foregroundColor(mood.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(mood.color.opacity(0.15))
                .cornerRadius(999)
            }

            if dream.isLucid {
                HStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                    Text("Lucid")
                        .font(AppFonts.callout)
                }
                .foregroundColor(AppColors.nebulaPink)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.nebulaPink.opacity(0.15))
                .cornerRadius(999)
            }
        }
    }

    private func recurringBadge(count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "repeat")
                .font(.caption)
            Text("Recurring dream — \(count) variation\(count == 1 ? "" : "s")")
                .font(AppFonts.caption)
        }
        .foregroundColor(AppColors.starGold)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.starGold.opacity(0.15))
        .cornerRadius(999)
    }

    @ViewBuilder
    private var photoSection: some View {
        if let url = dream.attachedPhotoURL,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dream Context")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 250)
                    .clipped()
                    .cornerRadius(16)
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    NavigationStack {
        DreamDetailView(dream: .sampleLucid)
            .environmentObject(JournalViewModel())
    }
}
