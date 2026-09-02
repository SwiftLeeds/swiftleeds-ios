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

    @Test func whenNoQueryItemsAreAppended_shouldBuildURLWithoutQuery() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource"))
        #expect(request.url == expected)
    }

    @Test func whenOneQueryItemIsAppended_shouldBuildURLWithThatQuery() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [URLQueryItem(name: "event", value: "abc")])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?event=abc"))
        #expect(request.url == expected)
    }

    @Test func whenSeveralQueryItemsAreAppended_shouldKeepTheirOrder() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [
                URLQueryItem(name: "a", value: "1"),
                URLQueryItem(name: "b", value: "2"),
            ])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?a=1&b=2"))
        #expect(request.url == expected)
    }

    @Test func whenQueryItemValueNeedsEncoding_shouldPercentEncodeIt() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [URLQueryItem(name: "q", value: "a b&c=d")])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?q=a%20b%26c%3Dd"))
        #expect(request.url == expected)
    }

    @Test func whenQueryItemHasNoValue_shouldBuildURLWithBareName() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [URLQueryItem(name: "flag", value: nil)])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?flag"))
        #expect(request.url == expected)
    }

    @Test func whenQueryItemsAreAppendedTwice_shouldCarryBothSets() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [URLQueryItem(name: "a", value: "1")])
            .appending(queryItems: [URLQueryItem(name: "b", value: "2")])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?a=1&b=2"))
        #expect(request.url == expected)
    }

    @Test func whenQueryItemsAreAppendedToPOST_shouldKeepMethodAndContent() throws {
        let bytes = Data(#"{"ticket": "ABCD-12"}"#.utf8)

        let request = try HTTPRequest.post(Self.path, content: .json(bytes))
            .appending(queryItems: [URLQueryItem(name: "a", value: "1")])
            .urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "POST")
        #expect(request.httpBody == bytes)
    }

    @Test func whenHeaderFieldIsAppended_shouldWriteItOntoRequest() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(headerField: .accept, "application/json")
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenHeaderFieldIsAppendedWithMediaType_shouldWriteItsString() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(headerField: .accept, .application.json)
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenHeaderFieldsAreAppendedTwice_shouldWriteBoth() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(headerField: .accept, "application/json")
            .appending(headerField: .ifNoneMatch, "\"abc\"")
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "If-None-Match") == "\"abc\"")
    }

    @Test func whenTwoHeaderFieldsShareName_shouldWriteLastOne() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(headerField: .accept, "text/plain")
            .appending(headerField: .accept, "application/json")
            .urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenHeaderFieldAndQueryItemAreAppended_shouldCarryBoth() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(headerField: .accept, .application.json)
            .appending(queryItems: [URLQueryItem(name: "event", value: "abc")])
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?event=abc"))
        #expect(request.url == expected)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenQueryItemAndHeaderFieldAreAppended_shouldCarryBoth() throws {
        let request = try HTTPRequest.get(Self.path)
            .appending(queryItems: [URLQueryItem(name: "event", value: "abc")])
            .appending(headerField: .accept, .application.json)
            .urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/resource?event=abc"))
        #expect(request.url == expected)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func whenHeaderFieldCompetesWithContentType_shouldKeepTypeOfContent() throws {
        let request = try HTTPRequest.post(Self.path, content: .json(Data()))
            .appending(headerField: .contentType, "text/plain")
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
