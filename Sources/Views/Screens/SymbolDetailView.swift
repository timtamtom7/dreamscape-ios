import SwiftUI

struct SymbolDetailView: View {
    let symbol: Symbol

    @EnvironmentObject var symbolsViewModel: SymbolsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(symbol.category.color.opacity(0.2))
                                        .frame(width: 56, height: 56)

                                    Image(systemName: symbol.category.icon)
                                        .font(.title2)
                                        .foregroundColor(symbol.category.color)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(symbol.name)
                                        .font(AppFonts.titleSmall)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text(symbol.category.displayName)
                                        .font(AppFonts.caption)
                                        .foregroundColor(symbol.category.color)
                                }
                            }

                            HStack(spacing: 24) {
                                StatBadge(
                                    title: "Appearances",
                                    value: "\(symbol.frequency)"
                                )

                                StatBadge(
                                    title: "Last Seen",
                                    value: symbol.lastSeen.relativeFormatted()
                                )
                            }
                        }

                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        // Timeline placeholder
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Occurrence Timeline")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            // Simple timeline visualization
                            TimelineBar(frequency: symbol.frequency)
                        }

                        Divider()
                            .background(AppColors.textMuted.opacity(0.3))

                        // Dreams containing this symbol
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dreams (\(symbolsViewModel.dreamsForSymbol.count))")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            if symbolsViewModel.dreamsForSymbol.isEmpty {
                                Text("No dreams found")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                ForEach(symbolsViewModel.dreamsForSymbol) { dream in
                                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                                        DreamCard(dream: dream)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Spacer(minLength: 50)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.auroraCyan)
                }
            }
            .onAppear {
                symbolsViewModel.loadDreamsForSymbol(symbol)
            }
        }
    }
}

struct StatBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct TimelineBar: View {
    let frequency: Int

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<12, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            index < min(frequency, 12) ?
                            AppColors.auroraCyan :
                            AppColors.surface
                        )
                        .frame(height: 24)
                }
            }
        }
        .frame(height: 32)
        .padding(.vertical, 8)
    }
}

#Preview {
    SymbolDetailView(symbol: Symbol.samples[0])
        .environmentObject(SymbolsViewModel())
}
