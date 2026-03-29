import SwiftUI

struct MenuBarView: View {
    @State private var store = DreamStore()
    @State private var selectedTab: Tab = .journal
    @State private var showingNewDream = false

    enum Tab: String, CaseIterable {
        case journal = "Journal"
        case stats = "Stats"

        var icon: String {
            switch self {
            case .journal: return "book.fill"
            case .stats: return "chart.bar.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            Theme.deepVoid
                .ignoresSafeArea()

            VStack(spacing: 0) {
                customTabBar

                TabView(selection: $selectedTab) {
                    DreamJournalView(store: store)
                        .tag(Tab.journal)

                    StatsView(store: store)
                        .tag(Tab.stats)
                }
                .tabViewStyle(.automatic)
            }
        }
        .frame(width: 360, height: 480)
        .sheet(isPresented: $showingNewDream) {
            NewDreamView(store: store, isPresented: $showingNewDream)
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14))
                        Text(tab.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == tab ? Theme.starGold : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Theme.cardBg : Color.clear)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 20)
                .background(Theme.distantStar)

            Button(action: { showingNewDream = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Log")
                        .font(.caption2)
                }
                .foregroundColor(Theme.auroraCyan)
                .frame(width: 60)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .background(Theme.surface)
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
