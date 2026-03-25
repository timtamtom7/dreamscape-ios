import SwiftUI

struct SymbolsListView: View {
    @EnvironmentObject var viewModel: SymbolsViewModel
    @State private var selectedSymbol: Symbol?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                if viewModel.symbols.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        // Search and sort
                        searchAndSortBar

                        // Symbols list
                        symbolsList
                    }
                }
            }
            .navigationTitle("Symbols")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.loadSymbols()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.circle")
                .font(.system(size: 64))
                .foregroundColor(AppColors.starGold.opacity(0.6))

            VStack(spacing: 8) {
                Text("No symbols detected")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Record dreams to discover recurring symbols")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var searchAndSortBar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMuted)

                TextField("Search symbols", text: $viewModel.searchText)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)

                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
            .padding(10)
            .background(AppColors.surface)
            .cornerRadius(12)

            // Sort button
            Button(action: { viewModel.toggleSortOrder() }) {
                Image(systemName: viewModel.sortByFrequency ? "chart.bar" : "textformat")
                    .foregroundColor(AppColors.textSecondary)
                    .padding(10)
                    .background(AppColors.surface)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var symbolsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(SymbolCategory.allCases, id: \.self) { category in
                    let categorySymbols = viewModel.symbolsByCategory()[category] ?? []

                    if !categorySymbols.isEmpty {
                        Section {
                            ForEach(categorySymbols) { symbol in
                                Button(action: { selectedSymbol = symbol }) {
                                    SymbolRow(symbol: symbol)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if symbol.id != categorySymbols.last?.id {
                                    Divider()
                                        .background(AppColors.textMuted.opacity(0.2))
                                        .padding(.leading, 60)
                                }
                            }
                        } header: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.displayName)
                                    .font(AppFonts.captionBold)
                                    .foregroundColor(category.color)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(AppColors.backgroundPrimary)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .sheet(item: $selectedSymbol) { symbol in
            SymbolDetailView(symbol: symbol)
        }
    }
}

struct SymbolRow: View {
    let symbol: Symbol

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(symbol.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: symbol.category.icon)
                    .font(.body)
                    .foregroundColor(symbol.category.color)
            }

            Text(symbol.name)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text("\(symbol.frequency)")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.surface)
                .cornerRadius(12)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    SymbolsListView()
        .environmentObject(SymbolsViewModel())
}
