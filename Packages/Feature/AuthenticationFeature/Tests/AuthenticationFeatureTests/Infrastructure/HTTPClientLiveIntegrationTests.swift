import AuthenticationDomain
import AuthenticationInfrastructure
import Dependencies
import Foundation
import LogKit
import LogKitTestSupport
import NetworkKit
import NetworkKitTestSupport
import Testing

/// Integration tests of ``HTTPClient/live(transport:onSessionExpiry:)``.
@Suite struct HTTPClientLiveIntegrationTests {
    /// The URL every request in this suite targets.
    private let url: URL

    /// Creates the suite with the URL every request targets.
    ///
    /// - Throws: An error when the fixed URL text does not parse.
    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    /// The chain returns the transport's body and status unchanged.
    @Test func whenLiveChainSendsRequest_shouldReturnServerResponse() async throws {
        let expected = Data("pong".utf8)
        let spy = HTTPClientSpy(respondingWith: expected, statusCode: 200)
        let store = InMemorySessionStore()

        let (data, response) = try await withDependencies {
            $0.log = LogRecorder().log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(transport: spy.httpClient, onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        #expect(data == expected)
        #expect(response.statusCode == 200)
    }

    /// The chain logs one event per request.
    @Test func whenLiveChainGetsResponse_shouldLogExactlyOnce() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 500)
        let recorder = LogRecorder()
        let store = InMemorySessionStore()

        _ = try await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(transport: spy.httpClient, onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        #expect(recorder.events.count == 1)
    }

    /// The chain sends the stored session's token as a bearer.
    @Test func whenSessionExists_shouldSendBearerThroughLiveChain() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 200)
        let token = try SessionToken("jwt-abc-123")
        let store = InMemorySessionStore(stored: Session(token: token))

        _ = try await withDependencies {
            $0.log = LogRecorder().log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(transport: spy.httpClient, onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        #expect(await spy.actions == [.send(request(bearing: token))])
    }

    /// A 401 on a request the chain gave a bearer reports session expiry.
    @Test func whenBearerRequestGets401_shouldReportSessionExpiry() async throws {
        let spy = HTTPClientSpy(respondingWith: Data(), statusCode: 401)
        let store = InMemorySessionStore(stored: Session(token: try SessionToken("jwt-abc-123")))

        try await confirmation("session expiry reported") { expired in
            _ = try await withDependencies {
                $0.log = LogRecorder().log
                $0.sessionStore = store.sessionStore
            } operation: {
                let sut = HTTPClient.live(transport: spy.httpClient, onSessionExpiry: { expired() })
                return try await sut.send(URLRequest(url: url))
            }
        }
    }

    /// Returns a request to `url` that carries `token` as its bearer.
    ///
    /// - Parameter token: The token to send.
    /// - Returns: The request, with its `Authorization` header set.
    private func request(bearing token: SessionToken) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(String(token))", forHTTPHeaderField: "Authorization")
        return request
    }
}
