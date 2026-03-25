import SwiftUI

struct DreamMapView: View {
    @EnvironmentObject var viewModel: DreamMapViewModel
    @State private var selectedSymbolForDetail: Symbol?
    @State private var mapScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var mapOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

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

                        // Zoom indicator
                        zoomIndicator

                        // Map canvas with pinch-to-zoom
                        GeometryReader { geometry in
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
                            .scaleEffect(mapScale)
                            .offset(mapOffset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        mapScale = min(max(mapScale * delta, 0.5), 3.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        mapOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = mapOffset
                                    }
                            )
                            .gesture(
                                TapGesture(count: 2)
                                    .onEnded {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            mapScale = 1.0
                                            mapOffset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                            )
                        }
                        .padding()

                        // Instructions
                        HStack(spacing: 16) {
                            Text("Pinch to zoom • Drag to pan")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                            Text("•")
                                .foregroundColor(AppColors.textMuted)
                            Text("Tap a symbol for details")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Dream Map")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            mapScale = 1.0
                            mapOffset = .zero
                            lastOffset = .zero
                        }
                        viewModel.loadData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
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

    private var zoomIndicator: some View {
        Text("Zoom: \(Int(mapScale * 100))%")
            .font(AppFonts.caption)
            .foregroundColor(AppColors.textMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppColors.surface.opacity(0.8))
            .cornerRadius(8)
    }

    private var timeFilterPicker: some View {
        HStack(spacing: 0) {
            ForEach(MapTimeFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.setTimeFilter(filter)
                    }
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
