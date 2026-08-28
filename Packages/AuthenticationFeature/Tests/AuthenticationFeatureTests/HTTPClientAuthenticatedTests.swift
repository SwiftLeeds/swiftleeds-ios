import AuthenticationFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

@Suite struct HTTPClientAuthenticatedTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    @Test func whenSessionExists_shouldAttachBearer() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
        let store = InMemorySessionStore(stored: Session(token: try SessionToken("jwt-abc-123")))

        _ = try await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            try await spy.httpClient.authenticated().send(URLRequest(url: url))
        }

        let request = try #require(await spy.requests.first)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer jwt-abc-123")
    }

    @Test func whenNoSession_shouldNotAttachBearer() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
        let store = InMemorySessionStore()

        _ = try await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            try await spy.httpClient.authenticated().send(URLRequest(url: url))
        }

        let request = try #require(await spy.requests.first)
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }
}
