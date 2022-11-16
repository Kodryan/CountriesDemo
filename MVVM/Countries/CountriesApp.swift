
import SwiftUI

@main
struct CountriesApp: App {
    var body: some Scene {
        WindowGroup {
            CountriesView(viewModel: .init())
        }
    }
}
