import Dependencies
import Foundation
import NetworkKit

extension SponsorsQuery: DependencyKey {
    package static var liveValue: SponsorsQuery {
        SponsorsQuery { () async throws(SponsorFetchError) -> [Sponsor] in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.sponsorMapper) var sponsorMapper

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(Endpoint.sponsors.urlRequest())
            } catch {
                throw SponsorFetchError.couldNotReachServer
            }

            do throws(SponsorMapper.ResponseError) {
                return try sponsorMapper.map(data, response)
            } catch {
                throw SponsorFetchError(error)
            }
        }
    }
}
