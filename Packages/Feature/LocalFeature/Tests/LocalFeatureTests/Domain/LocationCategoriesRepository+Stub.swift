import LocalFeature

extension LocationCategoriesRepository {
    static func returning(_ categories: [LocationCategory]) -> LocationCategoriesRepository {
        LocationCategoriesRepository { categories }
    }

    static func failing(with error: LocationCategoryFetchError) -> LocationCategoriesRepository {
        LocationCategoriesRepository { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            throw error
        }
    }
}
