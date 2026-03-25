import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary.ignoresSafeArea()

            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "moon.stars.fill",
                        iconColor: AppColors.nebulaPink,
                        title: "Welcome to Dreamscape",
                        description: "Your personal dream journal and AI-powered dream interpreter. Explore the depths of your subconscious mind."
                    )
                    .tag(0)

                    OnboardingPage(
                        icon: "brain.head.profile",
                        iconColor: AppColors.auroraCyan,
                        title: "AI Dream Analysis",
                        description: "Our advanced AI interprets your dreams, identifies recurring symbols, and surfaces patterns you might miss."
                    )
                    .tag(1)

                    OnboardingPage(
                        icon: "star.fill",
                        iconColor: AppColors.starGold,
                        title: "Track Symbol Evolution",
                        description: "Watch how your dream symbols change over time. Your personal dream dictionary grows with every entry."
                    )
                    .tag(2)

                    OnboardingPage(
                        icon: "heart.fill",
                        iconColor: AppColors.nebulaPink,
                        title: "Share with Family",
                        description: "Connect with partners and family to discover dreams you share and symbols that connect you."
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Skip/Continue buttons
                VStack(spacing: 16) {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(currentPage == 3 ? "Start Dreaming" : "Continue")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.auroraCyan)
                            .cornerRadius(12)
                    }

                    if currentPage < 3 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        isOnboardingComplete = false
    }
}

struct OnboardingPage: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: icon)
                    .font(.system(size: 72))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 16) {
                Text(title)
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}
