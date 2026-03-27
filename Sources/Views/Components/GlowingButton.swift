import SwiftUI

struct GlowingButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @State private var isPressed = false

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(AppFonts.headline)
            }
            .foregroundColor(AppColors.backgroundPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minWidth: DesignTokens.TouchTarget.minimum, minHeight: DesignTokens.TouchTarget.minimum)
            .background(
                Capsule()
                    .fill(AppColors.auroraCyan)
                    .shadow(color: AppColors.auroraCyan.opacity(isPressed ? 0.3 : 0.5), radius: isPressed ? 4 : 10, x: 0, y: isPressed ? 2 : 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .accessibilityLabel(title)
        .accessibilityHint(icon != nil ? "\(icon!) button" : "Primary action button")
        .accessibilityAddTraits(.isButton)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                Text(title)
                    .font(AppFonts.subheadline)
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(minWidth: DesignTokens.TouchTarget.minimum, minHeight: DesignTokens.TouchTarget.minimum)
            .background(
                Capsule()
                    .fill(AppColors.surface)
            )
            .overlay(
                Capsule()
                    .stroke(AppColors.textMuted.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint(icon != nil ? "\(icon!) button" : "Secondary action button")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: 20) {
            GlowingButton(title: "Save Dream", icon: "sparkles") {}
            SecondaryButton(title: "Cancel", icon: "xmark") {}
        }
    }
}
