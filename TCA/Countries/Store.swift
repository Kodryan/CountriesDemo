
import Foundation
import ComposableArchitecture

typealias LogAnalytic = (String) -> Void

struct Countries: ReducerProtocol {
    struct State: Equatable {
        var searchQuery = ""
        var isError: Bool = false
        var message: String = ""
        var populationCandles: [PopulationCandle] = []
        var isQueryValid = false

        struct PopulationCandle: Equatable {
            let year: String
            let populationMillions: Int
        }


    }

    enum Action: Equatable {
        case searchQueryChanged(String)
        case submitButtonTapped
        case loadCountry(CountryResponse)
    }

    @Dependency(\.countriesClient) var countriesClient
    @Dependency(\.logAnalytics) var logAnalytics

    func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        switch action {
        case let .searchQueryChanged(query):
            state.searchQuery = query
            state.isQueryValid = state.searchQuery.count > 4
            return .none
        case .submitButtonTapped:
            enum CancelID {}
            return .concatenate(
                .task { [query = state.searchQuery] in
                        .loadCountry(
                            try await countriesClient.searchCountry(.init(country: query))
                        )
                }.cancellable(id: CancelID.self, cancelInFlight: true)
            )
        case let .loadCountry(countryResponse):
            state.isError = countryResponse.error
            state.message = countryResponse.message
            state.populationCandles = countryResponse.populationCounts?.suffix(10).map {
                .init(year: String($0.year), populationMillions: $0.value / 1_000_000)
            } ?? []
            return .none
        }
    }
}

struct Analytics: ReducerProtocol {
    struct State: Equatable {
        var lastLoggedCountry: String = ""
    }

    enum Action: Equatable {
        case logCountry(String)
    }

    @Dependency(\.logAnalytics) var logAnalytics

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .logCountry(country):
            if state.lastLoggedCountry != country {
                logAnalytics(country)
                state.lastLoggedCountry = country
            }
            return .none
        }
    }
}

struct SharedState: ReducerProtocol {
    struct State: Equatable {
        var countries = Countries.State()
        var analytics = Analytics.State()
    }

    enum Action {
        case countries(Countries.Action)
        case analytics(Analytics.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.countries, action: /Action.countries) {
            Countries()
        }
        Scope(state: \.analytics, action: /Action.analytics) {
            Analytics().dependency(\.countriesClient, .live)
        }

        Reduce { state, action in
            switch action {
            case let .countries(countriesAction):
                switch countriesAction {
                case .loadCountry(let response):
                    return EffectTask(value: .analytics(.logCountry(response.country!)))

                default: return .none
                }

            case .analytics:
                return .none
            }
        }
    }
}


