import SwiftUI

// MARK: - View Extensions

extension View {
    func cosmicBackground() -> some View {
        self.background(AppColors.backgroundPrimary.ignoresSafeArea())
    }

    func cardStyle() -> some View {
        self
            .background(AppColors.surface)
            .cornerRadius(16)
            .shadow(color: AppColors.cardGlow, radius: 8, x: 0, y: 4)
    }

    func glowingBorder(color: Color = AppColors.auroraCyan, width: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: width)
        )
    }

    func fadeInAnimation(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .animation(.easeIn(duration: 0.5).delay(delay), value: true)
    }
}

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func relativeFormatted() -> String {
        if isToday {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: self))"
        } else if isYesterday {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: self))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
}

// MARK: - String Extensions

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}

// MARK: - Array Extensions

extension Array where Element == Symbol {
    func symbolsByCategory() -> [SymbolCategory: [Symbol]] {
        Dictionary(grouping: self, by: { $0.category })
    }

    var totalFrequency: Int {
        reduce(0) { $0 + $1.frequency }
    }
}
