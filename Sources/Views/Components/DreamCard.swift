import SwiftUI

struct DreamCard: View {
    let dream: Dream
    var onTap: (() -> Void)?

    @State private var isAppearing = false

    private var accessibilityDescription: String {
        var desc = "Dream from \(dream.shortFormattedDate)"
        if let mood = dream.mood {
            desc += ", mood: \(mood.displayName)"
        }
        if dream.isLucid {
            desc += ", lucid dream"
        }
        if !dream.symbols.isEmpty {
            desc += ", \(dream.symbols.count) symbols detected"
        }
        let summary = dream.summary.isEmpty ? dream.content.truncated(to: 100) : dream.summary
        desc += ". \(summary)"
        return desc
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(dream.shortFormattedDate)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.auroraCyan)

                    // R2: Mood indicator dot (minimum 11pt, using 8pt is too small)
                    if let mood = dream.mood {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 8, height: 8) // Minimum visible size
                    }

                    // R2: Lucid indicator (fixed: was .system(size: 8), min 11pt)
                    if dream.isLucid {
                        Image(systemName: "eye.fill")
                            .font(AppFonts.captionSmall)
                            .foregroundColor(AppColors.nebulaPink)
                    }

                    Spacer()

                    if !dream.symbols.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(AppFonts.caption)
                            Text("\(dream.symbols.count)")
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Summary (fixed: was body(15) which is below 17pt body standard)
                Text(dream.summary.isEmpty ? dream.content.truncated(to: 100) : dream.summary)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Symbol chips preview
                if !dream.symbols.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(dream.symbols.prefix(3)) { symbol in
                                SymbolChip(symbol: symbol, compact: true)
                            }
                            if dream.symbols.count > 3 {
                                Text("+\(dream.symbols.count - 3)")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .stroke(AppColors.cardGlow, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to view dream details")
        .scaleEffect(isAppearing ? 1 : 0.95)
        .opacity(isAppearing ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAppearing = true
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        DreamCard(dream: .sample)
            .padding()
    }
}
