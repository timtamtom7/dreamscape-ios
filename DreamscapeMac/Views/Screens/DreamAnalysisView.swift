import SwiftUI

struct DreamAnalysisView: View {
    let analysis: String
    let symbols: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Theme.nebulaPink)
                Text("AI Analysis")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(Theme.starGold)
            }

            Text(analysis)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
                .lineSpacing(4)

            if !symbols.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme Interpretations")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)

                    ForEach(symbols.prefix(4), id: \.self) { symbol in
                        ThemeInterpretationRow(symbol: symbol)
                    }
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.cosmicPurple.opacity(0.3), Theme.nebulaPink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.nebulaPink.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ThemeInterpretationRow: View {
    let symbol: String

    private var interpretation: (title: String, meaning: String) {
        let interpretations: [String: (String, String)] = [
            "ocean": ("Ocean", "Represents deep emotions, the subconscious mind, and the flow of life energy"),
            "moon": ("Moon", "Symbolizes intuition, femininity, cycles, and the hidden aspects of self"),
            "stars": ("Stars", "Indicates hopes, aspirations, guidance, and connection to the divine"),
            "flight": ("Flight", "Suggests desire for freedom, transcendence, or escaping limitations"),
            "water": ("Water", "Emotions, purification, the unconscious mind, and renewal"),
            "forest": ("Forest", "Represents the unconscious, nature, mystery, or a journey within"),
            "house": ("House", "The self, different rooms symbolize different aspects of personality"),
            "city": ("City", "Social connections, the conscious mind, or feelings of being overwhelmed"),
            "books": ("Books", "Knowledge, wisdom, hidden secrets, or different paths in life"),
            "bird": ("Bird", "Freedom, spiritual elevation, or messages from the subconscious")
        ]
        return interpretations[symbol.lowercased()] ?? (symbol.capitalized, "A recurring symbol worth exploring in your dreamscape")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.caption)
                .foregroundColor(Theme.starGold)

            VStack(alignment: .leading, spacing: 2) {
                Text(interpretation.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)

                Text(interpretation.meaning)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(8)
        .background(Theme.cardBg.opacity(0.5))
        .cornerRadius(8)
    }
}
