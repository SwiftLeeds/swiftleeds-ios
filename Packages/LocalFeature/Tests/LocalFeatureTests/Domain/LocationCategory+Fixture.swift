import Foundation
import LocalFeature

extension LocationCategory {
    static func fixture(
        id: LocationCategoryID = LocationCategoryID(UUID()),
        name: String = "Food",
        symbolName: String = "fork.knife",
        locations: [Location] = []
    ) -> Self {
        LocationCategory(id: id, name: name, symbolName: symbolName, locations: locations)
    }
}
