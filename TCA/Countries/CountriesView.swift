
import SwiftUI
import Charts
import ComposableArchitecture

struct CountriesView: View {
    let store: StoreOf<Countries>

    struct ViewState: Equatable {
        var message: String
        var populationCandles: [PopulationCandle]
        var searchQuery: String
        var isQueryValid: Bool
        struct PopulationCandle: Equatable {
            let year: String
            let populationMillions: Int
        }

        init(_ countriesState: Countries.State) {
            message = countriesState.message
            populationCandles = countriesState.populationCandles.map {
                .init(year: $0.year, populationMillions: $0.populationMillions)
            }
            searchQuery = countriesState.searchQuery
            isQueryValid = countriesState.isQueryValid
        }
    }

    enum ViewAction: Equatable {
        case searchQueryChanged(String)
        case submitButtonTapped
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: Countries.Action.init
        ) { viewStore in
            VStack(spacing: 10) {
                Text(viewStore.state.message)

                Chart(viewStore.state.populationCandles, id: \.year) {
                    LineMark(
                        x: .value("Year", $0.year),
                        y: .value("Population", $0.populationMillions)
                    )
                    PointMark(
                        x: .value("Year", $0.year),
                        y: .value("Population", $0.populationMillions)
                    )
                }
                .frame(height: 300)

                TextField(
                    "Enter a country name",
                    text: .init(
                        get: { viewStore.state.searchQuery },
                        set: { viewStore.send(.searchQueryChanged($0)) }
                    )
                )

                .textFieldStyle(.roundedBorder)
                .padding()

                Button("Submit") {
                    viewStore.send(.submitButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewStore.state.isQueryValid)
            }
            .font(.largeTitle)
        }
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView(store: .init(initialState: .init(), reducer: Countries()))
    }
}

extension Countries.Action {
    init(_ viewAction: CountriesView.ViewAction) {
        switch viewAction {
        case .submitButtonTapped:
            self = .submitButtonTapped
        case let .searchQueryChanged(query):
            self = .searchQueryChanged(query)
        }
    }
}
