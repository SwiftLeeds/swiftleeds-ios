import AuthenticationFeature
import Dependencies
import Foundation
import Testing

/// Everything that touches `URLProtocolStub`'s shared state lives here, unit and wiring
/// alike: `.serialized` only serializes within one suite.
@Suite(.serialized)
struct HTTPClientURLSessionTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com"))
    }

    @Test func whenLiveChainSendsRequest_shouldReturnServerResponse() async throws {
        let expected = Data("pong".utf8)
        URLProtocolStub.stub(
            data: expected,
            response: try #require(
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            ),
            error: nil
        )
        let store = InMemorySessionStore()

        let (data, response) = try await withDependencies {
            $0.log = LogRecorder().log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(urlSession: URLProtocolStub.session(), onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        #expect(data == expected)
        #expect(response.statusCode == 200)
    }

    @Test func whenLiveChainGetsResponse_shouldLogExactlyOnce() async throws {
        URLProtocolStub.stub(
            data: Data(),
            response: try #require(
                HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            ),
            error: nil
        )
        let recorder = LogRecorder()
        let store = InMemorySessionStore()

        _ = try await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(urlSession: URLProtocolStub.session(), onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        #expect(recorder.events.count == 1)
    }

    @Test func whenSessionExists_shouldSendBearerThroughLiveChain() async throws {
        URLProtocolStub.lastRequest = nil
        URLProtocolStub.stub(
            data: Data(),
            response: try #require(
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            ),
            error: nil
        )
        let store = InMemorySessionStore(stored: Session(token: try SessionToken("jwt-abc-123")))

        _ = try await withDependencies {
            $0.log = LogRecorder().log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = HTTPClient.live(urlSession: URLProtocolStub.session(), onSessionExpiry: {})
            return try await sut.send(URLRequest(url: url))
        }

        let request = try #require(URLProtocolStub.lastRequest)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer jwt-abc-123")
    }

    @Test func whenServerResponds_shouldReturnDataAndHTTPResponse() async throws {
        let expected = Data("hello".utf8)
        URLProtocolStub.stub(
            data: expected,
            response: try #require(
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            ),
            error: nil
        )
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        let (data, response) = try await sut.send(URLRequest(url: url))

        #expect(data == expected)
        #expect(response.statusCode == 200)
    }

    @Test func whenTransportFails_shouldThrow() async {
        URLProtocolStub.stub(data: nil, response: nil, error: URLError(.notConnectedToInternet))
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        await #expect(throws: (any Error).self) {
            _ = try await sut.send(URLRequest(url: url))
        }
    }

    @Test func whenResponseIsNotHTTP_shouldThrow() async {
        URLProtocolStub.stub(
            data: Data(),
            response: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            error: nil
        )
        let sut = HTTPClient.urlSession(URLProtocolStub.session())

        await #expect(throws: (any Error).self) {
            _ = try await sut.send(URLRequest(url: url))
        }
    }
}
