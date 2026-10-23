import Foundation

/// The location categories as the backend sends them. Data only.
package struct LocationCategoryListDTO: Decodable {
    package let data: [LocationCategoryDTO]

    package init(data: [LocationCategoryDTO]) {
        self.data = data
    }

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

    package struct LocationDTO: Decodable {
        package enum CodingKeys: String, CodingKey {
            case id
            case name
            case lat
            case lon
            case url
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
}
