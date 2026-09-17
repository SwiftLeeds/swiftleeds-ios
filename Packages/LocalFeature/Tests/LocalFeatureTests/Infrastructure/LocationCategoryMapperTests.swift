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
}
