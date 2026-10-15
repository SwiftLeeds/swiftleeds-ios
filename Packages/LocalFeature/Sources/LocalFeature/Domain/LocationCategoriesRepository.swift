import Dependencies

/// The source of the location categories.
package struct LocationCategoriesRepository: Sendable {
    /// Fetches the location categories.
    /// - Throws: A ``LocationCategoryFetchError`` when the server cannot be
    ///   reached, or its response is refused or unexpected.
    package var fetch: @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]

    /// Creates a repository.
    package init(fetch: @escaping @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]) {
        self.fetch = fetch
    }
}

extension LocationCategoriesRepository: TestDependencyKey {
    /// A stub that reports an issue, then throws ``LocationCategoryFetchError/unknown``.
    package static let testValue = LocationCategoriesRepository(
        fetch: { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            reportIssue("LocationCategoriesRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    /// The location category repository the current context uses.
    package var locationCategoriesRepository: LocationCategoriesRepository {
        get { self[LocationCategoriesRepository.self] }
        set { self[LocationCategoriesRepository.self] = newValue }
    }
}
