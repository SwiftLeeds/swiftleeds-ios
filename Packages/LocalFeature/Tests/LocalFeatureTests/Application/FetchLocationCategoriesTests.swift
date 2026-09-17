import Dependencies
import LocalFeature
import Testing

@Suite struct FetchLocationCategoriesTests {
    @Test func whenRepositoryReturnsCategories_shouldReturnSameCategories() async throws {
        let expected = [
            LocationCategory.fixture(name: "Food"),
            LocationCategory.fixture(name: "Coffee"),
        ]

        let categories = try await withDependencies {
            $0.locationCategoriesRepository = .returning(expected)
        } operation: {
            try await FetchLocationCategories.liveValue()
        }

        #expect(categories == expected)
    }

    @Test func whenRepositoryThrows_shouldThrowSameError() async {
        await withDependencies {
            $0.locationCategoriesRepository = .failing(with: .couldNotReachServer)
        } operation: {
            await #expect(throws: LocationCategoryFetchError.couldNotReachServer) {
                try await FetchLocationCategories.liveValue()
            }
        }
    }
}
