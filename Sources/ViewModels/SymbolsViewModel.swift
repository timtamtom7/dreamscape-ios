import Foundation
import Combine

@MainActor
final class SymbolsViewModel: ObservableObject {
    @Published var symbols: [Symbol] = []
    @Published var filteredSymbols: [Symbol] = []
    @Published var searchText = ""
    @Published var sortByFrequency = true
    @Published var isLoading = false
    @Published var selectedSymbol: Symbol?
    @Published var dreamsForSymbol: [Dream] = []
    @Published var symbolDiaryEntriesMap: [UUID: [SymbolDiaryEntry]] = [:]

    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadSymbols()
    }

    private func setupBindings() {
        $searchText
            .combineLatest($sortByFrequency)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText, sortByFrequency in
                self?.filterSymbols(searchText: searchText, sortByFrequency: sortByFrequency)
            }
            .store(in: &cancellables)
    }

    func loadSymbols() {
        isLoading = true

        do {
            symbols = try databaseService.fetchAllSymbols()
            filterSymbols(searchText: searchText, sortByFrequency: sortByFrequency)
        } catch {
            print("Error loading symbols: \(error)")
        }

        isLoading = false
    }

    private func filterSymbols(searchText: String, sortByFrequency: Bool) {
        var result = symbols

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        if sortByFrequency {
            result.sort { $0.frequency > $1.frequency }
        } else {
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        filteredSymbols = result
    }

    func loadDreamsForSymbol(_ symbol: Symbol) {
        selectedSymbol = symbol

        do {
            dreamsForSymbol = try databaseService.fetchDreamsForSymbol(symbolId: symbol.id)
        } catch {
            print("Error loading dreams for symbol: \(error)")
            dreamsForSymbol = []
        }
    }

    func symbolsByCategory() -> [SymbolCategory: [Symbol]] {
        Dictionary(grouping: filteredSymbols, by: { $0.category })
    }

    func toggleSortOrder() {
        sortByFrequency.toggle()
    }

    func symbolDiaryEntries(for symbolId: UUID) -> [SymbolDiaryEntry] {
        symbolDiaryEntriesMap[symbolId] ?? []
    }
}
