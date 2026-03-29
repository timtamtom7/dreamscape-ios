import SwiftUI

struct DreamCard: View {
    let dream: Dream
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.date, style: .date)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)

                        Text(dream.title)
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        LucidityIndicator(level: dream.lucidityLevel)

                        Text(dream.mood.emoji)
                            .font(.title3)
                    }
                }

                if let summary = dream.summary {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                } else {
                    Text(dream.narrative)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    MoodTag(mood: dream.mood)

                    if !dream.detectedSymbols.isEmpty {
                        SymbolCountBadge(count: dream.detectedSymbols.count)
                    }

                    Spacer()

                    if dream.isAnalyzed {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(Theme.starGold)
                    }
                }
            }
            .padding(16)
            .background(Theme.cardGradient)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.cosmicPurple.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Theme.cosmicPurple.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct MoodTag: View {
    let mood: Dream.Mood

    var body: some View {
        HStack(spacing: 4) {
            Text(mood.emoji)
            Text(mood.rawValue)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(hex: mood.color).opacity(0.2))
        .foregroundColor(Color(hex: mood.color))
        .cornerRadius(999)
    }
}

struct SymbolCountBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.circle.fill")
                .font(.caption2)
            Text("\(count)")
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.starGold.opacity(0.2))
        .foregroundColor(Theme.starGold)
        .cornerRadius(999)
    }
}

struct LucidityIndicator: View {
    let level: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Theme.auroraCyan : Theme.distantStar)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct GlowingButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Theme.cosmicPurple, Theme.nebulaPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    if isHovered {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: Theme.cosmicPurple.opacity(isHovered ? 0.6 : 0.3), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 6 : 3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}
