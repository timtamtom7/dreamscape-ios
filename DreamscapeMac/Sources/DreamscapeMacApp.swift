import SwiftUI

@main
struct DreamscapeMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
