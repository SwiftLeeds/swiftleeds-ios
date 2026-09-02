import Foundation
import NetworkKit
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
        let request = try HTTPRequest.post("api/v1/login/ticket", content: .json(Data()))
            .urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "POST")
    }

    @Test func whenPOSTIsBuilt_shouldCarryContentGiven() throws {
        let bytes = Data(#"{"ticket": "ABCD-12"}"#.utf8)

        let request = try HTTPRequest.post("api/v1/login/ticket", content: .json(bytes))
            .urlRequest(baseURL: baseURL)

        #expect(request.httpBody == bytes)
    }

    @Test func whenPOSTIsBuilt_shouldDeclareJSONContentType() throws {
        let request = try HTTPRequest.post("api/v1/login/ticket", content: .json(Data()))
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    private static let path: URLPath = "api/v1/resource"

    private static let requestsWithoutContent: [(HTTPRequest, String)] = [
        (.get(path), "GET"),
        (.head(path), "HEAD"),
        (.delete(path), "DELETE"),
        (.connect(path), "CONNECT"),
        (.options(path), "OPTIONS"),
        (.trace(path), "TRACE"),
    ]

    private static let requestsWithContent: [(HTTPRequest, String)] = [
        (.post(path, content: .json(Data())), "POST"),
        (.put(path, content: .json(Data())), "PUT"),
        (.patch(path, content: .json(Data())), "PATCH"),
    ]

    @Test(arguments: requestsWithoutContent)
    func whenMethodHasNoDefinedContent_shouldBuildWithoutContent(
        request: HTTPRequest,
        token: String
    ) throws {
        let built = try request.urlRequest(baseURL: baseURL)

        #expect(built.httpMethod == token)
        #expect(built.httpBody == nil)
    }

    @Test(arguments: requestsWithContent)
    func whenMethodDefinesContent_shouldBuildWithContent(
        request: HTTPRequest,
        token: String
    ) throws {
        let built = try request.urlRequest(baseURL: baseURL)

        #expect(built.httpMethod == token)
        #expect(built.httpBody != nil)
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
