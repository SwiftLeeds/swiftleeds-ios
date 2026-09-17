import Dependencies
import Foundation
import NetworkKit

extension LocationCategoriesRepository: DependencyKey {
    package static var liveValue: LocationCategoriesRepository {
        LocationCategoriesRepository { () async throws(LocationCategoryFetchError) -> [LocationCategory] in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.locationCategoryMapper) var locationCategoryMapper

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(Endpoint.local.urlRequest())
            } catch {
                throw LocationCategoryFetchError.couldNotReachServer
            }

            guard response.status == .ok else {
                throw LocationCategoryFetchError.unknown
            }

            let list: LocationCategoryListDTO
            do {
                list = try JSONDecoder().decode(LocationCategoryListDTO.self, from: data)
            } catch {
                throw LocationCategoryFetchError.invalidResponse
            }

            do throws(LocationCategoryMapper.MappingError) {
                return try locationCategoryMapper.map(list)
            } catch {
                throw LocationCategoryFetchError.invalidResponse
            }
        }
    }
}
