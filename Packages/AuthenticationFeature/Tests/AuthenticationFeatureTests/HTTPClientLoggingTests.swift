import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

/// Transport failures are logged here rather than per feature, so every request in the app is
/// covered by one decorator.
@Suite struct HTTPClientLoggingTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com/api/v1/login/ticket?token=secret"))
    }

    @Test func whenTransportFails_shouldLogMethodAndPath() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let event = try #require(await attempt(request))

        #expect(event.level == .error)
        let logged = try #require(event.fields.first { String($0.name) == "request" })
        #expect(logged.value == .string("POST /api/v1/login/ticket"))
    }

    /// A URL's query can carry credentials, and headers carry the bearer token, so neither reaches
    /// the log.
    @Test func whenTransportFails_shouldNotLogQuery() async throws {
        let event = try #require(await attempt(URLRequest(url: url)))

        let logged = try #require(event.fields.first { String($0.name) == "request" })
        #expect(logged.value == .string("GET /api/v1/login/ticket"))
    }

    @Test func whenTransportFails_shouldLogReason() async throws {
        let event = try #require(await attempt(URLRequest(url: url)))

        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    /// A 500 reached us, so nothing about the transport failed. Whoever reads the response decides
    /// whether that is worth logging.
    @Test func whenServerRespondsWithErrorStatus_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = HTTPClient.responding(with: Data(), statusCode: 500).logging()
            return try await sut.send(URLRequest(url: url))
        }

        #expect(recorder.events.isEmpty)
    }

    private func attempt(_ request: URLRequest) async -> LogEvent? {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = HTTPClient.failing(with: StubFailure.couldNotBuildResponse).logging()
            _ = try await sut.send(request)
        }

        return recorder.events.first
    }
}
