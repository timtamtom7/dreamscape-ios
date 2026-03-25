import SwiftUI

struct ContentView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var dreamMapViewModel: DreamMapViewModel
    @EnvironmentObject var symbolsViewModel: SymbolsViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel

    @State private var selectedTab = 0
    @State private var showingRecurringAnalysis = false
    @State private var showingLucidCoach = false
    @State private var showingSleepLab = false
    @State private var showingCommunity = false

    var body: some View {
        ZStack {
            // Background
            StarFieldBackground(starCount: 100)

            // Main content
            TabView(selection: $selectedTab) {
                // Journal Tab
                JournalTabHost(showingRecurringAnalysis: $showingRecurringAnalysis, showingSleepLab: $showingSleepLab, showingCommunity: $showingCommunity)
                    .tabItem {
                        Label("Journal", systemImage: "house.fill")
                    }
                    .tag(0)

                DreamMapView()
                    .tabItem {
                        Label("Map", systemImage: "sparkles")
                    }
                    .tag(1)

                SymbolsListView()
                    .tabItem {
                        Label("Symbols", systemImage: "star.circle.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(AppColors.auroraCyan)
        }
        .sheet(isPresented: $showingRecurringAnalysis) {
            RecurringDreamAnalysisView()
        }
        .sheet(isPresented: $showingLucidCoach) {
            LucidDreamingCoachView()
        }
        .environmentObject(galleryViewModel)
    }
}

// MARK: - Journal Tab Host

struct JournalTabHost: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @Binding var showingRecurringAnalysis: Bool
    @Binding var showingSleepLab: Bool
    @Binding var showingCommunity: Bool
    @State private var selectedSection: JournalSection = .dreams
    @State private var showingGallery = false
    @State private var showingSleepCorrelation = false

    enum JournalSection: String, CaseIterable {
        case dreams = "Dreams"
        case gallery = "Gallery"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // R4: Widget Dashboard
                    WidgetDashboardView(showingEntrySheet: $viewModel.showingEntrySheet)
                        .padding(.top, 8)

                    // Section picker
                    sectionPicker
                        .padding(.horizontal)
                        .padding(.top, 12)

                    // Content
                    if selectedSection == .dreams {
                        DreamListViewContent(showingRecurringAnalysis: $showingRecurringAnalysis)
                    } else {
                        DreamGalleryContent(showingSleepCorrelation: $showingSleepCorrelation)
                    }
                }
            }
            .navigationTitle("Dreamscape")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: { showingRecurringAnalysis = true }) {
                            Image(systemName: "repeat.circle")
                                .foregroundColor(AppColors.starGold)
                        }

                        // R4: Sleep Lab
                        Button(action: { showingSleepLab = true }) {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(AppColors.nebulaPink)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // R4: Community
                        Button(action: { showingCommunity = true }) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(AppColors.auroraCyan)
                        }

                        NavigationLink(destination: LucidDreamingCoachView()) {
                            Image(systemName: "eye.fill")
                                .foregroundColor(AppColors.nebulaPink)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSleepLab) {
            SleepLabView()
        }
        .sheet(isPresented: $showingCommunity) {
            CommunityView()
        }
    }

    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(JournalSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedSection = section
                    }
                }) {
                    Text(section.rawValue)
                        .font(AppFonts.callout)
                        .foregroundColor(
                            selectedSection == section ? AppColors.backgroundPrimary : AppColors.textSecondary
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    selectedSection == section ? AppColors.auroraCyan : Color.clear
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(AppColors.surface)
        .cornerRadius(20)
    }
}

// MARK: - Dream List View Content

struct DreamListViewContent: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @Binding var showingRecurringAnalysis: Bool

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingState
            } else if let error = viewModel.errorMessage {
                errorState(message: error)
            } else if viewModel.dreams.isEmpty {
                emptyState
            } else {
                dreamList
            }

            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingActionButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEntrySheet) {
            DreamEntryView()
        }
        .refreshable {
            await viewModel.refreshDreams()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "moon.stars")
                .font(.system(size: 64))
                .foregroundColor(AppColors.auroraCyan.opacity(0.6))

            VStack(spacing: 8) {
                Text("Your dreams await...")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Tap the + button to record your first dream")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.auroraCyan)

            Text("Loading your dreams...")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.warning)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(message)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { viewModel.loadDreams() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(AppFonts.callout)
                .foregroundColor(AppColors.backgroundPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppColors.auroraCyan)
                .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var dreamList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        AuroraDreamCard(dream: dream)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    private var floatingActionButton: some View {
        Button(action: {
            viewModel.showingEntrySheet = true
        }) {
            ZStack {
                Circle()
                    .fill(AppColors.auroraCyan)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.auroraCyan.opacity(0.5), radius: 10, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(AppColors.backgroundPrimary)
            }
        }
    }
}

// MARK: - Dream Gallery Content

struct DreamGalleryContent: View {
    @EnvironmentObject var viewModel: GalleryViewModel
    @Binding var showingSleepCorrelation: Bool

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingState
            } else if viewModel.galleryItems.isEmpty {
                emptyState
            } else {
                galleryContent
            }
        }
        .sheet(isPresented: $showingSleepCorrelation) {
            SleepCorrelationView()
        }
        .onAppear {
            viewModel.loadGallery()
        }
    }

    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.auroraCyan)

            Text("Generating your gallery...")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.stack")
                .font(.system(size: 64))
                .foregroundColor(AppColors.nebulaPink.opacity(0.6))

            VStack(spacing: 8) {
                Text("Your dream gallery awaits")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Record dreams to generate unique abstract art")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var galleryContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats row
                HStack(spacing: 16) {
                    StatCard(
                        icon: "photo.stack",
                        value: "\(viewModel.galleryItems.count)",
                        label: "Artworks"
                    )

                    StatCard(
                        icon: "sparkles",
                        value: "\(viewModel.totalSymbols)",
                        label: "Symbols"
                    )

                    Button(action: { showingSleepCorrelation = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(AppColors.auroraCyan)

                            Text(viewModel.correlationScore)
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Sleep")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // Gallery grid
                let columns = [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ]

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.galleryItems) { item in
                        GalleryArtCard(item: item) {
                            // Handle tap - could navigate to detail
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 100)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(JournalViewModel())
        .environmentObject(DreamMapViewModel())
        .environmentObject(SymbolsViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(GalleryViewModel())
}
