import Foundation
import LocalFeature
import Testing

@Suite struct LocationCategoryMapperTests {
    private let sut = LocationCategoryMapper.live

    @Test func whenListHasCategories_shouldMapEveryOneInOrder() throws {
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

    @Test func whenListIsEmpty_shouldMapToNoCategories() throws {
        #expect(try sut.map(LocationCategoryListDTO(data: [])).isEmpty)
    }

    @Test func whenCategoryHasLocations_shouldMapEveryOneInOrder() throws {
        let trinity = UUID()
        let brewSociety = UUID()
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [
                .fixture(id: trinity, name: "Trinity Kitchen"),
                .fixture(id: brewSociety, name: "Brew Society"),
            ]),
        ])

        let locations = try #require(sut.map(list).first?.locations)

        #expect(locations.map(\.id) == [LocationID(trinity), LocationID(brewSociety)])
        #expect(locations.map(\.name) == ["Trinity Kitchen", "Brew Society"])
    }

    @Test func whenLocationIsReadable_shouldMapItsLinkAndCoordinate() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [
                .fixture(lat: 53.797378, lon: -1.545209, url: "https://example.invalid/trinity-kitchen"),
            ]),
        ])

        let location = try #require(sut.map(list).first?.locations.first)

        #expect(location.websiteURL == URL(string: "https://example.invalid/trinity-kitchen"))
        #expect(location.coordinate == (try Coordinate(latitude: 53.797378, longitude: -1.545209)))
    }

    // MARK: - Refusals

    @Test func whenLatitudeIsOffTheGlobe_shouldNameTheLocationTheFieldAndTheValue() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(name: "Trinity Kitchen", lat: 91)]),
        ])

        do {
            _ = try sut.map(list)
            Issue.record("Expected a latitude off the globe to be refused")
        } catch {
            #expect(error.location == "Trinity Kitchen")
            #expect(error.field == .lat)
            #expect(error.value == "91.0")
        }
    }

    @Test func whenLongitudeIsOffTheGlobe_shouldNameTheLocationTheFieldAndTheValue() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(name: "Trinity Kitchen", lon: -181)]),
        ])

        do {
            _ = try sut.map(list)
            Issue.record("Expected a longitude off the globe to be refused")
        } catch {
            #expect(error.location == "Trinity Kitchen")
            #expect(error.field == .lon)
            #expect(error.value == "-181.0")
        }
    }

    @Test func whenLinkIsNotAURL_shouldNameTheLocationTheFieldAndTheValue() throws {
        let list = LocationCategoryListDTO(data: [
            .fixture(locations: [.fixture(name: "Trinity Kitchen", url: "")]),
        ])

        do {
            _ = try sut.map(list)
            Issue.record("Expected a link that is not a URL to be refused")
        } catch {
            #expect(error.location == "Trinity Kitchen")
            #expect(error.field == .url)
            #expect(error.value == "")
        }
    }
}
