
import SwiftUI
import Charts

struct CountriesView: View {
    @StateObject var viewModel: CountriesViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.state.message)

            Chart(viewModel.state.populationCandles, id: \.year) {
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
                text: $viewModel.state.searchQuery
            )
            .onChange(of: viewModel.state.searchQuery, perform: { _ in
                viewModel.searchQueryChanged()
            })
            .textFieldStyle(.roundedBorder)
            .padding()

            Button("Submit") {
                viewModel.submitButtonTapped()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.state.isQueryValid)
        }
        .font(.largeTitle)
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView(viewModel: .init())
    }
}
