import AuthenticationApplication
import AuthenticationDomain
import AuthenticationInfrastructure
import Dependencies
import Foundation
import LogKit
import LogKitTestSupport
import NetworkKit
import NetworkKitTestSupport
import Testing

/// Checks that the live `FetchProfile` reaches the live repository and the live mapper.
@Suite struct FetchProfileIntegrationTests {
    /// Only the live repository and mapper can produce this ticket slug from the JSON.
    @Test func whenResolvedInLiveContext_shouldReturnProfileFromServer() async throws {
        let configuration = APIConfiguration(baseURL: try #require(URL(string: "https://example.com")))

        let profile = try await withDependencies {
            $0.context = .live
            $0.authHTTPClient = .responding(with: attendeeJSON(), statusCode: 200)
            $0.apiConfiguration = configuration
            $0.log = LogRecorder().log
        } operation: {
            @Dependency(\.fetchProfile) var sut
            return try await sut()
        }

        #expect(profile.ticketSlug == (try TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ")))
    }
}
