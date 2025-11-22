import Foundation
import MapKit

struct Local: Decodable {
    let data: [LocationCategory]

    struct LocationCategory: Decodable, Identifiable, Equatable {
        let id: UUID
        let name: String
        let symbolName: String
        let locations: [Location]
    }

    struct Location: Decodable, Identifiable, Equatable {
        let id: UUID
        let name: String
        let url: URL
        let location: CLLocation
    }
}

extension Local.Location {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        url = try values.decode(URL.self, forKey: .url)

        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        location = CLLocation(latitude: latitude, longitude: longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, latitude = "lat", longitude = "lon", url
    }
}
