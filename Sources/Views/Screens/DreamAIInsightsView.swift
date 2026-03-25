import SwiftUI

/// Displays emotional journey through a dream + shadow work prompts + integration suggestion
struct DreamAIInsightsView: View {
    let dream: Dream
    let analysis: DreamAnalysisResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Emotional Journey Map
                if !analysis.emotionalJourney.isEmpty {
                    emotionalJourneySection
                }

                // Shadow Work Prompts
                if !analysis.shadowWorkPrompts.isEmpty {
                    shadowWorkSection
                }

                // Integration Suggestion
                if !analysis.integrationSuggestion.isEmpty {
                    integrationSection
                }

                // Narrative Arc
                if analysis.narrativeArc.totalSegments > 0 {
                    narrativeArcSection
                }
            }
            .padding()
        }
    }

    private var emotionalJourneySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Emotional Journey")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("How your feelings evolved through the dream")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            // Journey visualization
            HStack(spacing: 4) {
                ForEach(analysis.emotionalJourney) { segment in
                    emotionSegmentBar(segment)
                }
            }
            .frame(height: 60)

            // Labels
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysis.emotionalJourney) { segment in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(emotionColor(segment.dominantEmotion))
                            .frame(width: 8, height: 8)

                        Text("Stage \(segment.order): \(segment.dominantEmotion)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        Spacer()

                        Text(intensityLabel(segment.intensity))
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func emotionSegmentBar(_ segment: EmotionalJourneySegment) -> some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(emotionGradient(segment.dominantEmotion))
                    .frame(height: geo.size.height * segment.intensity)
            }
        }
    }

    private func emotionColor(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happiness", "joy", "peace": return AppColors.success
        case "sadness", "melancholy": return Color(hex: "60A5FA")
        case "fear", "anxiety": return AppColors.warning
        case "anger": return AppColors.error
        case "love": return AppColors.nebulaPink
        case "freedom": return AppColors.auroraCyan
        default: return AppColors.textSecondary
        }
    }

    private func emotionGradient(_ emotion: String) -> LinearGradient {
        let color = emotionColor(emotion)
        return LinearGradient(
            colors: [color.opacity(0.8), color.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func intensityLabel(_ intensity: Double) -> String {
        if intensity >= 0.8 { return "Intense" }
        else if intensity >= 0.5 { return "Moderate" }
        else { return "Subtle" }
    }

    private var shadowWorkSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Shadow Work Prompts")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("Questions to explore what your subconscious is surfacing")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            ForEach(analysis.shadowWorkPrompts) { prompt in
                ShadowWorkPromptCard(prompt: prompt)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var integrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Integration Suggestion")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("This dream might be asking you to...")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            Text(analysis.integrationSuggestion)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(6)
        }
        .padding()
        .background(
            AppColors.surface
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.starGold.opacity(0.3), lineWidth: 1)
                )
        )
        .cornerRadius(16)
    }

    private var narrativeArcSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "theatermasks.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Narrative Arc")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(analysis.narrativeArc.arcType)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.nebulaPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.nebulaPink.opacity(0.15))
                    .cornerRadius(8)
            }

            if let beginning = analysis.narrativeArc.beginning, !beginning.isEmpty {
                narrativeSegment(label: "Beginning", text: beginning, icon: "1.circle.fill", color: AppColors.auroraCyan)
            }

            if let middle = analysis.narrativeArc.middle, !middle.isEmpty {
                narrativeSegment(label: "Middle", text: middle, icon: "2.circle.fill", color: AppColors.nebulaPink)
            }

            if let end = analysis.narrativeArc.end, !end.isEmpty {
                narrativeSegment(label: "End", text: end, icon: "3.circle.fill", color: AppColors.starGold)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private func narrativeSegment(label: String, text: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppFonts.caption)
                    .foregroundColor(color)

                Text(text)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(3)
            }
        }
    }
}

struct ShadowWorkPromptCard: View {
    let prompt: ShadowWorkPrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                categoryBadge
                if let theme = prompt.theme as String? {
                    Text(theme)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textMuted)
                }
                Spacer()
            }

            Text(prompt.question)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)

            if let symbol = prompt.relatedSymbol {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("Related to: \(symbol)")
                        .font(.caption)
                }
                .foregroundColor(AppColors.nebulaPink)
            }
        }
        .padding()
        .background(AppColors.surfaceElevated)
        .cornerRadius(12)
    }

    private var categoryBadge: some View {
        Text(prompt.category.rawValue)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(categoryColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(categoryColor.opacity(0.15))
            .cornerRadius(4)
    }

    private var categoryColor: Color {
        switch prompt.category {
        case .shadow: return AppColors.nebulaPink
        case .integration: return AppColors.success
        case .exploration: return AppColors.auroraCyan
        case .transformation: return AppColors.starGold
        }
    }
}
