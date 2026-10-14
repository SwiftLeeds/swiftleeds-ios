import Foundation
import LocalFeature
import Testing

@Suite struct LocationCategoryMapperTests {
    private let sut = LocationCategoryMapper.live

    @Test func whenListHasCategories_shouldReturnCategoriesInListOrder() throws {
        let food = UUID()
        let coffee = UUID()
        let list = LocationCategoryListDTO(data: [
            .fixture(id: food, name: "Food", symbolName: "takeoutbag.and.cup.and.straw.fill"),
            .fixture(id: coffee, name: "Coffee", symbolName: "cup.and.saucer.fill"),
        ])

        let categories = try sut.map(list)

        #expect(categories.map(\.id) == [LocationCategoryID(food), LocationCategoryID(coffee)])
        #expect(categories.map(\.name) == ["Food", "Coffee"])
        #expect(categories.map(\.symbolName) == ["takeoutbag.and.cup.and.straw.fill", "cup.and.saucer.fill"])
    }

    @Test func whenListIsEmpty_shouldReturnNoCategories() throws {
        #expect(try sut.map(LocationCategoryListDTO(data: [])).isEmpty)
    }

    @Test func whenCategoryHasLocations_shouldReturnLocationsInListOrder() throws {
        let trinity = UUID()
        let brewSociety = UUID()
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [
                .fixture(id: trinity, name: "Trinity Kitchen"),
                .fixture(id: brewSociety, name: "Brew Society"),
            ])
        ])

        let locations = try #require(sut.map(list).first?.locations)

        #expect(locations.map(\.id) == [LocationID(trinity), LocationID(brewSociety)])
        #expect(locations.map(\.name) == ["Trinity Kitchen", "Brew Society"])
    }

    @Test func whenLocationHasValidLinkAndCoordinate_shouldReturnWebsiteURLAndCoordinate() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [
                .fixture(lat: 53.797378, lon: -1.545209, url: "https://example.invalid/trinity-kitchen")
            ])
        ])

        let location = try #require(sut.map(list).first?.locations.first)

        #expect(location.websiteURL == URL(string: "https://example.invalid/trinity-kitchen"))
        #expect(location.coordinate == (try Coordinate(latitude: 53.797378, longitude: -1.545209)))
    }

    @Test func whenLocationHasHTTPLink_shouldReturnWebsiteURL() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(url: "http://example.invalid/trinity-kitchen")])
        ])

        let location = try #require(sut.map(list).first?.locations.first)

        #expect(location.websiteURL == URL(string: "http://example.invalid/trinity-kitchen"))
    }

    @Test func whenLocationHasUppercaseScheme_shouldReturnWebsiteURL() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(url: "HTTPS://example.invalid/trinity-kitchen")])
        ])

        let location = try #require(sut.map(list).first?.locations.first)

        #expect(location.websiteURL != nil)
    }

    @Test(
        arguments: [
            "",
            "trinityleeds.com",
            "tel:01130000000",
            "https://",
            "//example.com",
        ]
    )
    func whenLinkIsNotWebAddress_shouldReturnLocationWithNoWebsite(url: String) throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(url: url)])
        ])

        let location = try #require(sut.map(list).first?.locations.first)

        #expect(location.websiteURL == nil)
    }

    @Test func whenOneLocationHasGoodLinkAndOtherHasBadLink_shouldReturnBothLocations() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [
                .fixture(name: "Trinity Kitchen", url: "https://example.invalid/trinity-kitchen"),
                .fixture(name: "Brew Society", url: "trinityleeds.com"),
            ])
        ])

        let locations = try #require(sut.map(list).first?.locations)

        #expect(locations.map(\.name) == ["Trinity Kitchen", "Brew Society"])
        #expect(locations[0].websiteURL == URL(string: "https://example.invalid/trinity-kitchen"))
        #expect(locations[1].websiteURL == nil)
    }

    // MARK: - Refusals

    @Test func whenLatitudeIsOutOfRange_shouldThrowErrorWithLocationFieldAndValue() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(name: "Trinity Kitchen", lat: 91)])
        ])

        do {
            _ = try sut.map(list)
            Issue.record("Expected an out-of-range latitude to throw")
        } catch {
            #expect(error.location == "Trinity Kitchen")
            #expect(error.field == .lat)
            #expect(error.value == "91.0")
        }
    }

    @Test func whenLongitudeIsOutOfRange_shouldThrowErrorWithLocationFieldAndValue() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(name: "Trinity Kitchen", lon: -181)])
        ])

        do {
            _ = try sut.map(list)
            Issue.record("Expected an out-of-range longitude to throw")
        } catch {
            #expect(error.location == "Trinity Kitchen")
            #expect(error.field == .lon)
            #expect(error.value == "-181.0")
        }
    }

    @Test func whenOneLocationIsInvalid_shouldThrowForWholeList() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(name: "Food", locations: [.fixture()]),
            .fixture(name: "Coffee", locations: [.fixture(lat: 91)]),
        ])

        #expect(throws: LocationCategoryMapper.MappingError.self) {
            try sut.map(list)
        }
    }
}
