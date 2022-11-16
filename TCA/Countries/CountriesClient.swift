
import Foundation

struct CountryRequest: Encodable {
    let country: String
}

struct CountriesClient {
    let searchCountry: (CountryRequest) async throws -> CountryResponse
}

extension CountriesClient {
    static let live = CountriesClient(
        searchCountry: { query in
            let url = URL(string: "https://countriesnow.space/api/v0.1/countries/population")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode(CountryRequest(country: query.country))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let (responseData, _) = try await session.data(for: request)
            return try JSONDecoder().decode(
                CountryResponse.self,
                from: responseData
            )
        }
    )
}

import Dependencies
extension CountriesClient: DependencyKey {
    static let liveValue = CountriesClient.live
}

extension DependencyValues {
    var countriesClient: CountriesClient {
        get { self[CountriesClient.self] }
        set { self[CountriesClient.self] = newValue }
    }
    var logAnalytics: LogAnalytic { { print($0) }}
}
