import AboutFeature
import Foundation
import NetworkKit
import Testing

@Suite struct EndpointTests {
    @Test func whenTeamRequestIsBuilt_shouldUseGETMethod() throws {
        let request = try Endpoint.team.urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "GET")
    }

    @Test func whenTeamRequestIsBuilt_shouldTargetTeamPath() throws {
        let request = try Endpoint.team.urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v2/team"))
        #expect(request.url == expected)
    }

    @Test func whenTeamRequestIsBuilt_shouldAcceptJSON() throws {
        let request = try Endpoint.team.urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenTeamRequestIsBuilt_shouldHaveNoBody() throws {
        let request = try Endpoint.team.urlRequest(baseURL: baseURL)

        #expect(request.httpBody == nil)
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
