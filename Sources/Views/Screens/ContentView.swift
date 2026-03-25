import SwiftUI

struct ContentView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var dreamMapViewModel: DreamMapViewModel
    @EnvironmentObject var symbolsViewModel: SymbolsViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Background
            StarFieldBackground(starCount: 100)

            // Main content
            TabView(selection: $selectedTab) {
                DreamListView()
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
    }
}

#Preview {
    ContentView()
        .environmentObject(JournalViewModel())
        .environmentObject(DreamMapViewModel())
        .environmentObject(SymbolsViewModel())
        .environmentObject(SettingsViewModel())
}
