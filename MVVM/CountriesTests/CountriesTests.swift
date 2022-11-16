
import XCTest
@testable import Countries

class CountriesTests: XCTestCase {
    func testSearchQueryChanged() {
        let viewModel = CountriesViewModel(
            initialState: .init(searchQuery: "12345", isQueryValid: false),
            countriesClient: .test
        )
        viewModel.searchQueryChanged()
        XCTAssertTrue(viewModel.state.isQueryValid)
    }

    func testSubmitButtonTapped() {
        let viewModel = CountriesViewModel(countriesClient: .test)
        viewModel.submitButtonTapped()
        XCTAssertEqual(viewModel.state.message, "test")
    }
}

extension CountryResponse {
    static let mock = CountryResponse(
        message: "test",
        error: false,
        populationCounts: [.init(year: 1992, value: 5)]
    )
}

extension CountriesClient {
    static let test = CountriesClient(
        searchCountry: { _ in .mock }
    )
}
