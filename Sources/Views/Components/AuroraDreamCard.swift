import SwiftUI

/// R3: Dream Card with Aurora-like gradient backgrounds
struct AuroraDreamCard: View {
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
        if dream.recurringVariantId != nil {
            desc += ", recurring dream"
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
                // Header with aurora accent
                HStack {
                    // Aurora accent bar
                    Rectangle()
                        .fill(auroraGradient)
                        .frame(width: 3, height: 16)
                        .cornerRadius(2)

                    Text(dream.shortFormattedDate)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.auroraCyan)

                    // R2: Mood indicator dot (minimum 8pt visible indicator)
                    if let mood = dream.mood {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 8, height: 8)
                    }

                    // R2: Lucid indicator (fixed: was .system(size: 8), min 11pt)
                    if dream.isLucid {
                        Image(systemName: "eye.fill")
                            .font(AppFonts.captionSmall)
                            .foregroundColor(AppColors.nebulaPink)
                    }

                    // Recurring indicator (fixed: was .system(size: 8), min 11pt)
                    if dream.recurringVariantId != nil {
                        Image(systemName: "repeat")
                            .font(AppFonts.captionSmall)
                            .foregroundColor(AppColors.starGold)
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

                // Summary with aurora text gradient for important dreams
                Text(dream.summary.isEmpty ? dream.content.truncated(to: 100) : dream.summary)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Symbol chips preview with aurora style
                if !dream.symbols.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(dream.symbols.prefix(3)) { symbol in
                                AuroraSymbolChip(symbol: symbol, compact: true)
                            }
                            if dream.symbols.count > 3 {
                                Text("+\(dream.symbols.count - 3)")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                }

                // Aurora glow at bottom for special dreams
                if dream.isLucid || dream.mood == .exhilarating || dream.mood == .peaceful {
                    AuroraGlow()
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .stroke(auroraBorderColor.opacity(0.3), lineWidth: 1)
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

    private var auroraGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.auroraCyan, AppColors.nebulaPink, AppColors.starGold],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var auroraBorderColor: Color {
        if dream.isLucid {
            return AppColors.nebulaPink
        } else if dream.mood == .exhilarating {
            return AppColors.starGold
        } else if dream.mood == .peaceful {
            return AppColors.auroraCyan
        } else if dream.recurringVariantId != nil {
            return AppColors.starGold.opacity(0.5)
        }
        return AppColors.cardGlow
    }
}

// MARK: - Aurora Symbol Chip

struct AuroraSymbolChip: View {
    let symbol: Symbol
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol.category.icon)
                .font(compact ? .caption2 : .caption)
                .foregroundColor(symbol.category.color)

            if !compact {
                Text(symbol.name)
                    .font(AppFonts.callout)
                    .foregroundColor(symbol.category.color)
            }
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            Capsule()
                .fill(symbol.category.color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(symbol.category.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Aurora Glow

struct AuroraGlow: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppColors.auroraCyan.opacity(0.3),
                AppColors.nebulaPink.opacity(0.2),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 2)
        .cornerRadius(1)
    }
}

// MARK: - Animated Aurora Background

struct AuroraBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                // Draw flowing aurora bands
                for i in 0..<3 {
                    var path = Path()
                    let index = CGFloat(i + 1)
                    let baseY = size.height * index / 4 + CGFloat(sin(t * 0.3 + Double(i) * 2)) * 20

                    path.move(to: CGPoint(x: 0, y: baseY))

                    for x in stride(from: CGFloat.zero, to: size.width, by: 5) {
                        let y = baseY + CGFloat(sin(Double(x) * 0.01 + t * 0.5 + Double(i))) * 15
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()

                    let colors: [Color] = [AppColors.auroraCyan, AppColors.nebulaPink, AppColors.starGold]
                    context.fill(path, with: .color(colors[i].opacity(0.08)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Smooth Transition Modifier

struct SmoothTransition: ViewModifier {
    @State private var isActive = false

    func body(content: Content) -> some View {
        content
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity.combined(with: .scale(scale: 1.02))
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isActive)
    }
}

extension View {
    func smoothTransition() -> some View {
        modifier(SmoothTransition())
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: 16) {
            AuroraDreamCard(dream: .sample)
            AuroraDreamCard(dream: .sampleLucid)
        }
        .padding()
    }
}
