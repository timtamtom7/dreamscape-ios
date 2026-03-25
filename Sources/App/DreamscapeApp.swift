import SwiftUI

@main
struct DreamscapeApp: App {
    @StateObject private var journalViewModel = JournalViewModel()
    @StateObject private var dreamMapViewModel = DreamMapViewModel()
    @StateObject private var symbolsViewModel = SymbolsViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(journalViewModel)
                .environmentObject(dreamMapViewModel)
                .environmentObject(symbolsViewModel)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
