import Foundation
import SwiftUI

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case plus = "plus"
    case pro = "pro"
    case lifetime = "lifetime"

    // R13: Subscription pricing
    var monthlyPrice: Double? {
        switch self {
        case .free: return nil
        case .plus: return 9.99
        case .pro: return 19.99
        case .lifetime: return nil
        }
    }

    var lifetimePrice: Double? {
        switch self {
        case .lifetime: return 199.0
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .plus: return "Plus"
        case .pro: return "Pro"
        case .lifetime: return "Lifetime"
        }
    }

    var maxDreamsPerMonth: Int? { nil } // unlimited
    static var freeMaxDreams: Int { 3 }

    var monthlyLimit: Int? {
        switch self {
        case .free: return 3
        case .plus, .pro, .lifetime: return nil
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return ["3 dreams/month", "Basic AI analysis", "Symbol tracking"]
        case .plus:
            return ["Unlimited dreams", "Cloud sync", "All AI features", "Advanced analytics", "Sleep correlation"]
        case .pro:
            return ["Everything in Plus", "Family sharing", "Export & backup", "iPad & macOS", "Priority AI processing", "Memorial mode"]
        case .lifetime:
            return ["Everything in Pro", "One-time payment", "Lifetime access", "Early features", "VIP support"]
        }
    }

    var color: Color {
        switch self {
        case .free: return .gray
        case .plus: return AppColors.auroraCyan
        case .pro: return AppColors.starGold
        case .lifetime: return .purple
        }
    }

    var icon: String {
        switch self {
        case .free: return "leaf.fill"
        case .plus: return "star.fill"
        case .pro: return "crown.fill"
        case .lifetime: return "infinity.circle.fill"
        }
    }
}

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    private let tierKey = "dreamscape_subscription_tier"
    private let proUnlockedKey = "dreamscape_pro_unlocked"

    @Published var currentTier: SubscriptionTier = .free

    var isPro: Bool { currentTier == .pro }
    var isPlus: Bool { currentTier == .plus || currentTier == .pro }

    var dreamsThisMonth: Int {
        let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return JournalViewModel().dreams.filter { $0.createdAt >= monthStart }.count
    }

    var canAddDream: Bool {
        if isPlus { return true }
        return dreamsThisMonth < SubscriptionTier.freeMaxDreams
    }

    var dreamsRemaining: Int {
        if isPlus { return Int.max }
        return max(0, SubscriptionTier.freeMaxDreams - dreamsThisMonth)
    }

    init() {
        loadTier()
    }

    func loadTier() {
        if let tierString = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: tierString) {
            currentTier = tier
        } else if UserDefaults.standard.bool(forKey: proUnlockedKey) {
            currentTier = .pro
        } else {
            currentTier = .free
        }
    }

    func upgrade(to tier: SubscriptionTier) {
        currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
        if tier == .pro {
            UserDefaults.standard.set(true, forKey: proUnlockedKey)
        }
    }

    func simulatePurchase(tier: SubscriptionTier) {
        upgrade(to: tier)
    }
}
