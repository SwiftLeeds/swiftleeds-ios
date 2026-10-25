import AuthenticationDomain
import AuthenticationInfrastructure
import Dependencies
import Foundation
import NetworkKit
import NetworkKitTestSupport
import Testing

@Suite struct HTTPClientAuthenticatedTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    @Test func whenSessionExists_shouldAttachBearer() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
        let store = InMemorySessionStore(stored: Session(token: try SessionToken("jwt-abc-123")))
        var expected = URLRequest(url: url)
        expected.setValue("Bearer jwt-abc-123", forHTTPHeaderField: "Authorization")

        _ = try await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            try await spy.httpClient.authenticated().send(URLRequest(url: url))
        }

        #expect(await spy.actions == [.send(expected)])
    }

    @Test func whenNoSession_shouldSendRequestUnchanged() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
        let store = InMemorySessionStore()

        _ = try await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            try await spy.httpClient.authenticated().send(URLRequest(url: url))
        }

        #expect(await spy.actions == [.send(URLRequest(url: url))])
    }
}
