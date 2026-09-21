#if os(iOS)
import DesignKit
import Foundation
import LocalFeature
import LocalUI
import SwiftUI
import Testing

@MainActor
@Suite struct BottomSheetViewSnapshotTests {
    @Test func firstSelected() throws {
        let categories = try [LocationCategory].foodAndDrink
        let view = GeometryReader { proxy in
            BottomSheetView(
                isOpen: .constant(true),
                selectedCategory: .constant(categories.first),
                categories: categories,
                maxHeight: proxy.size.height * Constants.maxHeightRatio
            )
        }

        assertScreenSnapshots(of: view)
    }
}

private extension [LocationCategory] {
    static var foodAndDrink: [LocationCategory] {
        get throws {
            [
                .category(
                    named: "Food",
                    symbolName: "takeoutbag.and.cup.and.straw.fill",
                    locations: [
                        try .location(
                            named: "Trinity Kitchen",
                            websiteURL: "https://trinityleeds.com/shops/trinity-kitchen",
                            coordinate: try Coordinate(latitude: 53.797378, longitude: -1.545209)
                        ),
                    ]
                ),
                .category(
                    named: "Drinks",
                    symbolName: "wineglass.fill",
                    locations: [
                        try .location(
                            named: "Brew Society",
                            websiteURL: "https://www.brewsociety.co.uk/",
                            coordinate: try Coordinate(latitude: 53.795840, longitude: -1.550339)
                        ),
                    ]
                ),
            ]
        }
    }
}

private extension LocationCategory {
    static func category(named name: String, symbolName: String, locations: [Location]) -> LocationCategory {
        LocationCategory(
            id: LocationCategoryID(UUID()),
            name: name,
            symbolName: symbolName,
            locations: locations
        )
    }
}

private extension Location {
    static func location(named name: String, websiteURL: String, coordinate: Coordinate) throws -> Location {
        Location(
            id: LocationID(UUID()),
            name: name,
            websiteURL: try #require(URL(string: websiteURL)),
            coordinate: coordinate
        )
    }
}
#endif
