
import Foundation

struct CountriesState {
    var searchQuery = ""
    var isError: Bool = false
    var message: String = ""
    var populationCandles: [PopulationCandle] = []
    var isQueryValid = false

    struct PopulationCandle {
        let year: String
        let populationMillions: Int
    }
}

final class CountriesViewModel: ObservableObject {

    @Published var state: CountriesState

    private let countriesClient: CountriesClient

    init(
        initialState: CountriesState = .init(),
        countriesClient: CountriesClient = .live
    ) {
        self.countriesClient = countriesClient
        state = initialState
    }

    func searchQueryChanged() {
        state.isQueryValid = state.searchQuery.count > 4
    }

    func submitButtonTapped() {
        loadCountry(state.searchQuery)
    }

    private func loadCountry(_ countryName: String) {
        Task { @MainActor in
            let countryResponse = try await countriesClient.searchCountry(.init(country: countryName))
            state.isError = countryResponse.error
            state.message = countryResponse.message
            state.populationCandles = countryResponse.populationCounts?.suffix(10).map {
                .init(year: String($0.year), populationMillions: $0.value / 1_000_000)
            } ?? []
        }
    }
}
