import AuthenticationFeature
import Foundation
import NetworkKit
import Testing

@Suite struct EndpointTests {
    @Test func whenLoginRequestIsBuilt_shouldPOST() throws {
        let request = try Endpoint.login(content: Data()).urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "POST")
    }

    @Test func whenLoginRequestIsBuilt_shouldTargetLoginTicketPath() throws {
        let request = try Endpoint.login(content: Data()).urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/login/ticket"))
        #expect(request.url == expected)
    }

    @Test func whenLoginRequestIsBuilt_shouldDeclareJSONContentType() throws {
        let request = try Endpoint.login(content: Data()).urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func whenLoginRequestIsBuilt_shouldCarryContentGiven() throws {
        let content = Data(#"{"ticket": "ABCD-12"}"#.utf8)

        let request = try Endpoint.login(content: content).urlRequest(baseURL: baseURL)

        #expect(request.httpBody == content)
    }

    @Test func whenTicketRequestIsBuilt_shouldGET() throws {
        let request = try Endpoint.ticket.urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "GET")
    }

    @Test func whenTicketRequestIsBuilt_shouldTargetLoginTicketPath() throws {
        let request = try Endpoint.ticket.urlRequest(baseURL: baseURL)

        let expected = try #require(URL(string: "https://example.com/api/v1/login/ticket"))
        #expect(request.url == expected)
    }

    @Test func whenTicketRequestIsBuilt_shouldCarryNoContent() throws {
        let request = try Endpoint.ticket.urlRequest(baseURL: baseURL)

        #expect(request.httpBody == nil)
    }

    @Test func whenTicketRequestIsBuilt_shouldDeclareNoContentType() throws {
        let request = try Endpoint.ticket.urlRequest(baseURL: baseURL)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
