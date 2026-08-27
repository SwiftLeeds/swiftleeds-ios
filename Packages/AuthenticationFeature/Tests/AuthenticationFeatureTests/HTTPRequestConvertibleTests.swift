import AuthenticationFeature
import Foundation
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
}
