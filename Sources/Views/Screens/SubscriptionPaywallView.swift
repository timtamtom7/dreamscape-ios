import SwiftUI

struct SubscriptionPaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var selectedTier: SubscriptionTier?
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        headerSection

                        // Current status
                        currentStatusSection

                        // Tier comparison
                        tierComparisonSection

                        // Upgrade buttons
                        upgradeButtonsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Unlock Dreams")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(AppColors.starGold)

            Text("Unlock Your Full Dreaming Mind")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Choose a plan to access unlimited dream recording and advanced AI features.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var currentStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Plan: \(subscriptionService.currentTier.displayName)")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            if subscriptionService.isPlus {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(subscriptionService.currentTier.color)
                    Text("You have full access")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                HStack {
                    Text("\(subscriptionService.dreamsRemaining) dreams remaining this month")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    if !subscriptionService.canAddDream {
                        Text("Limit reached")
                            .font(.caption)
                            .foregroundColor(AppColors.error)
                    }
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(12)
            }
        }
    }

    private var tierComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Your Plan")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                tierCard(tier)
            }
        }
    }

    private func tierCard(_ tier: SubscriptionTier) -> some View {
        Button {
            selectedTier = tier
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tier.icon)
                        .foregroundColor(tier.color)

                    Text(tier.displayName)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text(tierPrice(tier))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    if selectedTier == tier {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }

                ForEach(tier.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(AppColors.success)
                        Text(feature)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedTier == tier ? tier.color : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func tierPrice(_ tier: SubscriptionTier) -> String {
        switch tier {
        case .free: return "Free"
        case .plus: return "$4.99/mo"
        case .pro: return "$9.99/mo"
        }
    }

    private var upgradeButtonsSection: some View {
        VStack(spacing: 12) {
            if let tier = selectedTier, tier != .free {
                Button {
                    purchaseTier(tier)
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(AppColors.backgroundPrimary)
                    } else {
                        Text("Subscribe to \(tier.displayName)")
                    }
                }
                .font(AppFonts.headline)
                .foregroundColor(AppColors.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(tier.color)
                .cornerRadius(12)
                .disabled(isPurchasing)
            }

            Button {
                // Restore purchases
            } label: {
                Text("Restore Purchases")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.auroraCyan)
            }

            Text("Cancel anytime. Privacy policy and terms apply.")
                .font(.caption2)
                .foregroundColor(AppColors.textMuted)
        }
    }

    private func purchaseTier(_ tier: SubscriptionTier) {
        isPurchasing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            subscriptionService.simulatePurchase(tier: tier)
            isPurchasing = false
        }
    }
}

struct UpgradePromptBanner: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    let onUpgrade: () -> Void

    var body: some View {
        if !subscriptionService.canAddDream {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.starGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly limit reached")
                        .font(AppFonts.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Upgrade for unlimited dreams")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button {
                    onUpgrade()
                } label: {
                    Text("Upgrade")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.starGold)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(12)
        }
    }
}
