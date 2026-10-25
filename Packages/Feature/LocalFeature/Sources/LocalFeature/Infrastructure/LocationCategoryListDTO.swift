import Foundation

/// The location categories as the backend sends them. Data only.
package struct LocationCategoryListDTO: Decodable {
    /// One category of locations as the backend sends it.
    package struct LocationCategoryDTO: Decodable {
        package let id: UUID
        package let name: String
        package let symbolName: String
        package let locations: [LocationDTO]

        package init(id: UUID, name: String, symbolName: String, locations: [LocationDTO]) {
            self.id = id
            self.name = name
            self.symbolName = symbolName
            self.locations = locations
        }
    }

    /// One location as the backend sends it.
    package struct LocationDTO: Decodable {
        package enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case lat = "lat"
            case lon = "lon"
            case url = "url"
        }

        package let id: UUID
        package let name: String
        package let lat: Double
        package let lon: Double
        package let url: String

        package init(id: UUID, name: String, lat: Double, lon: Double, url: String) {
            self.id = id
            self.name = name
            self.lat = lat
            self.lon = lon
            self.url = url
        }
    }

    package let data: [LocationCategoryDTO]

    package init(data: [LocationCategoryDTO]) {
        self.data = data
    }
}
