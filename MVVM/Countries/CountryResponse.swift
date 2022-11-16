
struct CountryResponse: Decodable, Equatable {
    let message: String
    let error: Bool
    let populationCounts: [PopulationCounts]?

    struct PopulationCounts: Decodable, Equatable {
        let year: Int
        let value: Int
    }
}

extension CountryResponse {
    private enum CodingKeys: String, CodingKey {
        case message = "msg"
        case error
        case data
    }

    private enum NestedContainerKeys: String, CodingKey {
        case country
        case populationCounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try? container.nestedContainer(
            keyedBy: NestedContainerKeys.self,
            forKey: .data
        )
        message = try container.decode(String.self, forKey: .message)
        error = try container.decode(Bool.self, forKey: .error)
        populationCounts = try nestedContainer?.decodeIfPresent(
            [PopulationCounts].self,
            forKey: .populationCounts
        )

    }
}
