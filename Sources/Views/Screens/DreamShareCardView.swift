import SwiftUI

/// A beautiful shareable card for a dream — blurs identifying details by default
struct DreamShareCardView: View {
    let dream: Dream
    @State private var isBlurringNames = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Privacy toggle
                        privacyToggle

                        // Share card
                        shareCardContent
                            .padding(.horizontal)

                        // Symbol insight preview
                        symbolInsightCard
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Share Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: generateShareText(), subject: Text("My Dream"), message: Text("Shared from Dreamscape")) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
        }
    }

    private var privacyToggle: some View {
        HStack {
            Image(systemName: "eye.slash.fill")
                .foregroundColor(AppColors.auroraCyan)

            VStack(alignment: .leading, spacing: 2) {
                Text("Privacy Mode")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                Text("Names and places are blurred")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isBlurringNames)
                .labelsHidden()
                .tint(AppColors.auroraCyan)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var shareCardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.shortFormattedDate)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.auroraCyan)

                    if let mood = dream.mood {
                        HStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.caption2)
                            Text(mood.displayName)
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(mood.color)
                    }
                }

                Spacer()

                Image(systemName: "moon.stars.fill")
                    .foregroundColor(AppColors.nebulaPink)
            }

            // Dream content (with privacy blur)
            Text(privacyBlurredContent)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(5)

            // Photo attachment (blurred in privacy mode)
            if let photoURL = dream.attachedPhotoURL,
               let data = try? Data(contentsOf: photoURL),
               let uiImage = UIImage(data: data) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)

                    if isBlurringNames {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(height: 150)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "eye.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                            )
                    }
                }
            }

            // Symbol chips
            if !dream.symbols.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(dream.symbols.prefix(6)) { symbol in
                        HStack(spacing: 4) {
                            Image(systemName: symbol.category.icon)
                                .font(.caption2)
                            Text(symbol.name)
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(symbol.category.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(symbol.category.color.opacity(0.15))
                        .cornerRadius(999)
                    }
                }
            }

            // Footer
            HStack {
                Spacer()
                Text("Shared from Dreamscape ✦")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppColors.surface, AppColors.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.auroraCyan.opacity(0.3), AppColors.nebulaPink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var symbolInsightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Symbol Insight")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            if let topSymbol = dream.symbols.max(by: { $0.frequency < $1.frequency }) {
                Text("This dream featured **\(topSymbol.name)** — a \(topSymbol.category.displayName.lowercased()) that appeared in your dreams \(topSymbol.frequency) time\(topSymbol.frequency == 1 ? "" : "s").")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }

            if dream.symbols.count > 1 {
                Text("Other symbols: \(dream.symbols.dropFirst().prefix(3).map { $0.name }.joined(separator: ", "))")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    // MARK: - Privacy Blur

    private var privacyBlurredContent: String {
        guard isBlurringNames else { return dream.content }

        var content = dream.content

        // Collect person and place names to blur
        let namesToBlur = dream.symbols.filter { $0.category == .person || $0.category == .place }

        for symbol in namesToBlur {
            // Replace occurrences with blurred version
            let pattern = "\\b\(symbol.name)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(content.startIndex..., in: content)
                content = regex.stringByReplacingMatches(
                    in: content,
                    options: [],
                    range: range,
                    withTemplate: "[REDACTED]"
                )
            }
        }

        return content
    }

    private func generateShareText() -> String {
        var text = "🌙 \(dream.shortFormattedDate)\n\n"
        text += "\"\(privacyBlurredContent.truncated(to: 300))\"\n\n"

        if !dream.symbols.isEmpty {
            let symbolNames = dream.symbols.prefix(4).map { $0.name }
            text += "Symbols: \(symbolNames.joined(separator: " • "))"
        }

        text += "\n\nShared via Dreamscape ✦"
        return text
    }
}

#Preview {
    DreamShareCardView(dream: .sampleLucid)
}
