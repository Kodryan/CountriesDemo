
import SwiftUI
import ComposableArchitecture

@main
struct CountriesApp: App {
    let store = StoreOf<SharedState>(
        initialState: .init(),
        reducer: SharedState()
            .dependency(\.countriesClient, .live)
    )
    var body: some Scene {
        WindowGroup {
            CountriesView(store: store.scope(state: \.countries, action: SharedState.Action.countries))
        }
    }
}
