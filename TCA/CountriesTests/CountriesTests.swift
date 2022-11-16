
import XCTest
import ComposableArchitecture
@testable import Countries

class CountriesTests: XCTestCase {
    @MainActor
    func testSearchQueryChanged() async {
        let store = TestStore(
            initialState: .init(searchQuery: "", isQueryValid: false),
            reducer: Countries()
        )
        await _ = store.send(.searchQueryChanged("12345")) { state in
            state.searchQuery = "12345"
            state.isQueryValid = true
        }
    }

    @MainActor
    func testSubmitButtonTapped() async {
        let store = TestStore(
            initialState: .init(),
            reducer: Countries()
        )
        store.dependencies.countriesClient = .init(searchCountry: { _ in .mock })
        _ = await store.send(.submitButtonTapped)
        await store.receive(.loadCountry(.mock)) { state in
            state.message = "test"
            state.populationCandles = [ .init(year: "1992", populationMillions: 0) ]
        }
    }
}

extension CountryResponse {
    static let mock = CountryResponse(
        country: "test",
        message: "test",
        error: false,
        populationCounts: [.init(year: 1992, value: 5)]
    )
}
