import Foundation
import LocalFeature
import NetworkKit
import Testing

@Suite struct EndpointTests {
    @Test func whenLocalRequestIsBuilt_shouldUseGETMethod() throws {
        let request = try Endpoint.local.urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "GET")
    }

    @Test func whenLocalRequestIsBuilt_shouldTargetLocalPath() throws {
        let request = try Endpoint.local.urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/local"))
        #expect(request.url == expected)
    }

    @Test func whenLocalRequestIsBuilt_shouldAcceptJSON() throws {
        let request = try Endpoint.local.urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenLocalRequestIsBuilt_shouldHaveNoBody() throws {
        let request = try Endpoint.local.urlRequest(baseURL: baseURL)

        #expect(request.httpBody == nil)
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
