import SwiftUI

struct SymbolChip: View {
    let symbol: Symbol
    var compact: Bool = false
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 4) {
                if !compact {
                    Image(systemName: symbol.category.icon)
                        .font(.caption2)
                }

                Text(symbol.name)
                    .font(compact ? AppFonts.caption : AppFonts.callout)
            }
            .padding(.horizontal, compact ? 8 : 12)
            .padding(.vertical, compact ? 4 : 6)
            .background(
                Capsule()
                    .fill(isSelected ? symbol.category.color.opacity(0.3) : symbol.category.color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(symbol.category.color.opacity(isSelected ? 0.8 : 0.4), lineWidth: 1)
            )
            .foregroundColor(isSelected ? symbol.category.color : symbol.category.color.opacity(0.9))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SymbolChipRow: View {
    let symbols: [Symbol]
    var onSymbolTap: ((Symbol) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(symbols) { symbol in
                    SymbolChip(symbol: symbol, onTap: { onSymbolTap?(symbol) })
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: 16) {
            SymbolChip(symbol: Symbol(name: "Ocean", category: .place))
            SymbolChip(symbol: Symbol(name: "Flying", category: .emotion), isSelected: true)
            SymbolChip(symbol: Symbol(name: "Mother", category: .person), compact: true)
            SymbolChipRow(symbols: Symbol.samples)
        }
        .padding()
    }
}
