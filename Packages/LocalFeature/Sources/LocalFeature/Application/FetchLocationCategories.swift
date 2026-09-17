import Dependencies

public struct FetchLocationCategories: Sendable {
    private var perform: @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]

    public init(perform: @escaping @Sendable () async throws(LocationCategoryFetchError) -> [LocationCategory]) {
        self.perform = perform
    }

    public func callAsFunction() async throws(LocationCategoryFetchError) -> [LocationCategory] {
        try await perform()
    }
}

extension FetchLocationCategories: DependencyKey {
    public static var liveValue: FetchLocationCategories {
        FetchLocationCategories { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            @Dependency(\.locationCategoriesRepository) var locationCategoriesRepository
            return try await locationCategoriesRepository.fetch()
        }
    }

    public static let testValue = FetchLocationCategories(
        perform: { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            reportIssue("FetchLocationCategories is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchLocationCategories: FetchLocationCategories {
        get { self[FetchLocationCategories.self] }
        set { self[FetchLocationCategories.self] = newValue }
    }
}
