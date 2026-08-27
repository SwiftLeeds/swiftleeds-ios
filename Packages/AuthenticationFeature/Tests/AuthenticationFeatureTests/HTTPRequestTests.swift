import AuthenticationFeature
import Foundation
import Testing

@Suite struct HTTPRequestTests {
    @Test func whenGETIsBuilt_shouldUseGETMethod() throws {
        let request = try HTTPRequest.get("api/v1/login/ticket").urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "GET")
    }

    @Test func whenGETIsBuilt_shouldAppendPathToBaseURL() throws {
        let request = try HTTPRequest.get("api/v1/login/ticket").urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/login/ticket"))
        #expect(request.url == expected)
    }

    @Test func whenGETIsBuilt_shouldCarryNoBody() throws {
        let request = try HTTPRequest.get("api/v1/login/ticket").urlRequest(baseURL: baseURL)

        #expect(request.httpBody == nil)
    }

    @Test func whenGETIsBuilt_shouldDeclareNoContentType() throws {
        let request = try HTTPRequest.get("api/v1/login/ticket").urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test func whenPOSTIsBuilt_shouldUsePOSTMethod() throws {
        let request = try HTTPRequest.post("api/v1/login/ticket", body: .json(Data()))
            .urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "POST")
    }

    @Test func whenPOSTIsBuilt_shouldCarryBodyGiven() throws {
        let bytes = Data(#"{"ticket": "ABCD-12"}"#.utf8)

        let request = try HTTPRequest.post("api/v1/login/ticket", body: .json(bytes))
            .urlRequest(baseURL: baseURL)

        #expect(request.httpBody == bytes)
    }

    @Test func whenPOSTIsBuilt_shouldDeclareJSONContentType() throws {
        let request = try HTTPRequest.post("api/v1/login/ticket", body: .json(Data()))
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
