import SwiftUI

struct DreamMapView: View {
    @EnvironmentObject var viewModel: DreamMapViewModel
    @State private var selectedSymbolForDetail: Symbol?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                if viewModel.nodes.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        // Time filter
                        timeFilterPicker
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // Legend
                        legendView
                            .padding(.vertical, 12)

                        // Map canvas
                        DreamMapCanvas(
                            nodes: viewModel.nodes,
                            edges: viewModel.edges,
                            selectedNodeId: viewModel.selectedNodeId,
                            onNodeTap: { nodeId in
                                if let node = viewModel.nodes.first(where: { $0.id == nodeId }) {
                                    selectedSymbolForDetail = node.symbol
                                }
                            }
                        )
                        .padding()

                        // Instructions
                        Text("Tap a symbol to see details")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Dream Map")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedSymbolForDetail) { symbol in
                SymbolDetailView(symbol: symbol)
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(AppColors.nebulaPink.opacity(0.6))

            VStack(spacing: 8) {
                Text("No symbols yet")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Record dreams to start building your dream map")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var timeFilterPicker: some View {
        HStack(spacing: 0) {
            ForEach(MapTimeFilter.allCases, id: \.self) { filter in
                Button(action: {
                    viewModel.setTimeFilter(filter)
                }) {
                    Text(filter.rawValue)
                        .font(AppFonts.callout)
                        .foregroundColor(
                            viewModel.timeFilter == filter ? AppColors.backgroundPrimary : AppColors.textSecondary
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    viewModel.timeFilter == filter ? AppColors.auroraCyan : Color.clear
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(AppColors.surface)
        .cornerRadius(20)
    }

    private var legendView: some View {
        HStack(spacing: 16) {
            ForEach(SymbolCategory.allCases, id: \.self) { category in
                HStack(spacing: 4) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                    Text(category.displayName)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    DreamMapView()
        .environmentObject(DreamMapViewModel())
}
