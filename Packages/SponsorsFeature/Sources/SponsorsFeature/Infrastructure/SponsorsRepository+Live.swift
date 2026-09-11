import Dependencies
import Foundation
import NetworkKit

extension SponsorsRepository: DependencyKey {
    package static var liveValue: SponsorsRepository {
        SponsorsRepository { () async throws(SponsorFetchError) -> Sponsors in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.sponsorMapper) var sponsorMapper

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(Endpoint.sponsors.urlRequest())
            } catch {
                throw SponsorFetchError.couldNotReachServer
            }

            guard response.status == .ok else {
                throw SponsorFetchError.unknown
            }

            let list: SponsorListDTO
            do {
                list = try JSONDecoder().decode(SponsorListDTO.self, from: data)
            } catch {
                throw SponsorFetchError.invalidResponse
            }

            do throws(SponsorMapper.LevelError) {
                return try sponsorMapper.map(list)
            } catch {
                throw SponsorFetchError.invalidResponse
            }
        }
    }
}
