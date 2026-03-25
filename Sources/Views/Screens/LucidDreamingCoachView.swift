import SwiftUI

/// R3: Lucid Dreaming Coach — tips and guidance for lucid dreaming
struct LucidDreamingCoachView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTip: LucidTip?
    @State private var showWBTBSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        heroCard
                            .padding(.horizontal)

                        // Quick start tips
                        quickStartSection
                            .padding(.horizontal)

                        // WBTB Reminder toggle
                        wbtbSection
                            .padding(.horizontal)

                        // All tips by category
                        tipsByCategory
                            .padding(.horizontal)

                        // Dream sign recognition
                        dreamSignsSection
                            .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Lucid Coach")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.nebulaPink)

            Text("Lucid Dreaming Coach")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("Learn to become aware that you're dreaming while you're in the dream — and take control.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.nebulaPink.opacity(0.15), AppColors.surface],
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

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(AppColors.starGold)
                Text("Quick Start")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(LucidTip.quickStartTips) { tip in
                LucidTipRow(tip: tip) {
                    selectedTip = tip
                }
            }
        }
    }

    private var wbtbSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "alarm.fill")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Wake Back To Bed (WBTB)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("One of the most effective lucid dream techniques. Wake up after 4-6 hours of sleep, stay awake 20-30 minutes, then go back to sleep while keeping the intention to lucid dream.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)

            VStack(spacing: 8) {
                WBTBTipRow(
                    title: "Set an alarm",
                    description: "4-5 hours after going to bed"
                )

                WBTBTipRow(
                    title: "Stay awake",
                    description: "20-30 minutes of light activity"
                )

                WBTBTipRow(
                    title: "Visualize your dream",
                    description: "While falling back asleep"
                )
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var tipsByCategory: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Tips")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(LucidCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                        Text(category.displayName)
                            .font(AppFonts.subheadline)
                            .foregroundColor(category.color)
                    }

                    ForEach(LucidTip.tipsByCategory[category] ?? []) { tip in
                        LucidTipRow(tip: tip) {
                            selectedTip = tip
                        }
                    }
                }
            }
        }
    }

    private var dreamSignsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.auroraCyan)
                Text("Recognizing Dream Signs")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("These common dream patterns can help you realize you're dreaming:")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)

            FlowLayout(spacing: 8) {
                ForEach(DreamSign.examples, id: \.self) { sign in
                    Text(sign)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.auroraCyan)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.auroraCyan.opacity(0.15))
                        .cornerRadius(999)
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }
}

// MARK: - Lucid Tip Model

struct LucidTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: LucidCategory
    let icon: String
    let details: String

    static let quickStartTips: [LucidTip] = [
        LucidTip(
            title: "Reality Checks",
            description: "Ask yourself throughout the day: 'Am I dreaming?' — it becomes automatic in dreams.",
            category: .foundation,
            icon: "questionmark.circle.fill",
            details: "Perform 3-5 reality checks every hour. Common ones: plug your nose and try to breathe, look at your hands and count your fingers, check a clock twice to see if the time makes sense. In dreams, these often fail — making you realize you're dreaming."
        ),
        LucidTip(
            title: "Dream Journal",
            description: "Record your dreams immediately upon waking to improve recall.",
            category: .foundation,
            icon: "book.fill",
            details: "Keep a journal next to your bed. Write down everything you remember — even fragments, feelings, and colors. The more you practice recall, the more vivid your dreams become."
        ),
        LucidTip(
            title: "Intention Setting",
            description: "Before sleep, clearly intend to remember that you're dreaming.",
            category: .foundation,
            icon: "brain.head.profile",
            details: "As you fall asleep, repeat: 'I will know that I am dreaming' while visualizing yourself becoming lucid. This primes your subconscious for awareness during dreams."
        )
    ]

    static var tipsByCategory: [LucidCategory: [LucidTip]] {
        var result: [LucidCategory: [LucidTip]] = [:]
        for category in LucidCategory.allCases {
            result[category] = LucidTip.allTips.filter { $0.category == category }
        }
        return result
    }

    static var allTips: [LucidTip] {
        quickStartTips + [
            // Foundation
            LucidTip(
                title: "Sleep Hygiene",
                description: "Get 7-9 hours of consistent sleep for better dream recall.",
                category: .foundation,
                icon: "bed.double.fill",
                details: "Consistent sleep schedules, dark rooms, and avoiding screens before bed all improve sleep quality and dream recall. Dreams are most memorable during REM sleep, which increases toward morning."
            ),
            // Techniques
            LucidTip(
                title: "WBTB Technique",
                description: "Wake after 4-6 hours, stay awake 20-30 min, return to sleep with intent.",
                category: .techniques,
                icon: "alarm.fill",
                details: "The Wake Back To Bed technique exploits the natural increase in REM sleep after partial awakening. Your brain enters longer, more intense REM cycles, increasing chances of lucidity."
            ),
            LucidTip(
                title: "MILD Technique",
                description: "Repeat a mantra while falling asleep: 'I'll remember I'm dreaming.'",
                category: .techniques,
                icon: "brain",
                details: "Mnemonic Induced Lucid Dreaming (MILD) involves setting an intention as you fall asleep. Focus on the phrase while visualizing yourself in a recent dream, becoming lucid."
            ),
            LucidTip(
                title: "SSILD Technique",
                description: "Cycle through sensory vivid visualizations to induce lucidity.",
                category: .techniques,
                icon: "eye.fill",
                details: "Sense-Induced Lucid Sleep Dreaming involves briefly focusing on each sense (vision, hearing, touch) in rapid cycles, then returning to sleep. It works by increasing awareness during the transition to sleep."
            ),
            // Stabilization
            LucidTip(
                title: "Spin Technique",
                description: "If the dream starts fading, spin around to stabilize it.",
                category: .stabilization,
                icon: "arrow.2.circlepath",
                details: "When you realize you're dreaming, spinning can help stabilize the dream environment. Focus on the sensations of spinning — the world will solidify around you."
            ),
            LucidTip(
                title: "Hand Rubbing",
                description: "Rub your hands together in the dream to increase awareness.",
                category: .stabilization,
                icon: "hand.raised.fill",
                details: "Focusing on physical sensations in a dream — like rubbing your hands together — helps ground you in the dream and prevents it from dissolving."
            ),
            LucidTip(
                title: "Ground Rules",
                description: "Establish rules for your dream world to make it more stable.",
                category: .stabilization,
                icon: "checkmark.seal.fill",
                details: "In a lucid dream, if you know something is true (like your name or home address), the dream respects it. This 'grounding' helps stabilize the entire dream environment."
            ),
            // Adventure
            LucidTip(
                title: "Start Small",
                description: "Begin by simply looking at your hands or walking through a door.",
                category: .adventure,
                icon: "figure.walk",
                details: "Start with simple tasks in your lucid dreams. Look at your hands, examine a mirror, or walk through a doorway. These simple reality checks help you stay grounded while exploring."
            ),
            LucidTip(
                title: "Fly On Purpose",
                description: "Flying is one of the most exhilarating lucid dream experiences.",
                category: .adventure,
                icon: "airplane",
                details: "To fly in a lucid dream: jump and focus on the sensation of weightlessness. Once airborne, control your direction by tilting or using your intention. Start low and build confidence."
            ),
            LucidTip(
                title: "Meet Your Subconscious",
                description: "Characters in dreams can represent parts of your psyche.",
                category: .adventure,
                icon: "person.fill.questionmark",
                details: "Lucid dreams offer a unique opportunity to explore your subconscious. People you encounter may represent different aspects of yourself. Approach them with curiosity rather than fear."
            )
        ]
    }
}

enum LucidCategory: String, CaseIterable {
    case foundation = "Foundation"
    case techniques = "Techniques"
    case stabilization = "Stabilization"
    case adventure = "Adventure"

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .foundation: return AppColors.auroraCyan
        case .techniques: return AppColors.nebulaPink
        case .stabilization: return AppColors.starGold
        case .adventure: return AppColors.success
        }
    }

    var icon: String {
        switch self {
        case .foundation: return "building.2.fill"
        case .techniques: return "wand.and.stars"
        case .stabilization: return "anchor.fill"
        case .adventure: return "map.fill"
        }
    }
}

struct DreamSign {
    static let examples = [
        "Water appearing suddenly",
        "Teeth falling out",
        "Being chased",
        "Showing up late",
        "Flying or falling",
        "Phones not working",
        "Unfamiliar people",
        "Strange buildings",
        "Your childhood home",
        "School or exams",
        "Being naked",
        "Animals acting unusual"
    ]
}

// MARK: - Lucid Tip Row

struct LucidTipRow: View {
    let tip: LucidTip
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: tip.icon)
                            .font(.caption)
                            .foregroundColor(tip.category.color)
                        Text(tip.title)
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Text(tip.description)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WBTBTipRow: View {
    let title: String
    let description: String

    var body: some View {
        HStack {
            Circle()
                .fill(AppColors.auroraCyan)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textPrimary)

                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Tip Detail Sheet

struct LucidTipDetailSheet: View {
    let tip: LucidTip
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: tip.icon)
                                .font(.title2)
                                .foregroundColor(tip.category.color)

                            Text(tip.title)
                                .font(AppFonts.titleSmall)
                                .foregroundColor(AppColors.textPrimary)
                        }

                        Text(tip.description)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)

                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        Text("How it works")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text(tip.details)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineSpacing(5)

                        HStack {
                            Text("Category:")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)

                            Text(tip.category.displayName)
                                .font(AppFonts.caption)
                                .foregroundColor(tip.category.color)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Tip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }
            }
        }
    }
}

#Preview {
    LucidDreamingCoachView()
}
