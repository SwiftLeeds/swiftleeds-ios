import Dependencies
import Foundation
import NetworkKit

extension LocationCategoriesRepository: DependencyKey {
    package static var liveValue: LocationCategoriesRepository {
        LocationCategoriesRepository { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            @Dependency(\.httpClient) var httpClient

            let data: Data
            do {
                (data, _) = try await httpClient.send(Endpoint.local.urlRequest())
            } catch {
                throw LocationCategoryFetchError.couldNotReachServer
            }

            let list: LocationCategoryListDTO
            do {
                list = try JSONDecoder().decode(LocationCategoryListDTO.self, from: data)
            } catch {
                throw LocationCategoryFetchError.invalidResponse
            }

            do throws(LocationCategoryMapper.MappingError) {
                return try LocationCategoryMapper.live.map(list)
            } catch {
                throw LocationCategoryFetchError.unknown
            }
        }
    }
}
