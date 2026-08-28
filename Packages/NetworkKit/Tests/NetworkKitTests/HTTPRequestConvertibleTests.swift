import Dependencies
import Foundation
import NetworkKit
import Testing

@Suite struct HTTPRequestConvertibleTests {
    private struct ConvertibleStub: HTTPRequestConvertible {
        let request: HTTPRequest = .get("api/v1/resource")
    }

    @Test func whenConformerBuildsURLRequest_shouldBuildFromItsOwnRequest() throws {
        let baseURL = try #require(URL(string: "https://example.com"))

        let built = ConvertibleStub().urlRequest(baseURL: baseURL)

        #expect(built == HTTPRequest.get("api/v1/resource").urlRequest(baseURL: baseURL))
    }

    @Test func whenNoBaseURLIsGiven_shouldBuildAgainstConfiguredAPI() throws {
        let configured = try #require(URL(string: "https://configured.example.com"))

        let built = withDependencies {
            $0.apiConfiguration = APIConfiguration(baseURL: configured)
        } operation: {
            ConvertibleStub().urlRequest()
        }

        let expected = try #require(URL(string: "https://configured.example.com/api/v1/resource"))
        #expect(built.url == expected)
    }
}
