import SwiftUI

struct DreamCard: View {
    let dream: Dream
    var onTap: (() -> Void)?

    @State private var isAppearing = false

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(dream.shortFormattedDate)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.auroraCyan)

                    Spacer()

                    if !dream.symbols.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("\(dream.symbols.count)")
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Summary
                Text(dream.summary.isEmpty ? dream.content.truncated(to: 100) : dream.summary)
                    .font(AppFonts.body(15))
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.cardGlow, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
