import Dependencies

/// Reads the location categories.
package struct LocationCategoriesRepository: Sendable {
    package var fetch: @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]

    package init(fetch: @escaping @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]) {
        self.fetch = fetch
    }
}

extension LocationCategoriesRepository: TestDependencyKey {
    package static let testValue = LocationCategoriesRepository(
        fetch: { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            reportIssue("LocationCategoriesRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var locationCategoriesRepository: LocationCategoriesRepository {
        get { self[LocationCategoriesRepository.self] }
        set { self[LocationCategoriesRepository.self] = newValue }
    }
}
