import Foundation
import NetworkKit
import SponsorsFeature
import Testing

@Suite struct EndpointTests {
    @Test func whenSponsorsRequestIsBuilt_shouldGET() throws {
        let request = try Endpoint.sponsors.urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "GET")
    }

    @Test func whenSponsorsRequestIsBuilt_shouldTargetTheSponsorsPath() throws {
        let request = try Endpoint.sponsors.urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/sponsors"))
        #expect(request.url == expected)
    }

    @Test func whenSponsorsRequestIsBuilt_shouldCarryNoContent() throws {
        let request = try Endpoint.sponsors.urlRequest(baseURL: baseURL)

        #expect(request.httpBody == nil)
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
