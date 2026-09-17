import Foundation
import LocalFeature

extension LocationCategoryListDTO.LocationCategoryDTO {
    static func fixture(
        id: UUID = UUID(),
        name: String = "Food",
        symbolName: String = "takeoutbag.and.cup.and.straw.fill",
        locations: [LocationCategoryListDTO.LocationDTO] = []
    ) -> Self {
        LocationCategoryListDTO.LocationCategoryDTO(
            id: id,
            name: name,
            symbolName: symbolName,
            locations: locations
        )
    }
}

extension LocationCategoryListDTO.LocationDTO {
    static func fixture(
        id: UUID = UUID(),
        name: String = "Trinity Kitchen",
        lat: Double = 53.797378,
        lon: Double = -1.545209,
        url: String = "https://example.invalid/trinity-kitchen"
    ) -> Self {
        LocationCategoryListDTO.LocationDTO(id: id, name: name, lat: lat, lon: lon, url: url)
    }
}
