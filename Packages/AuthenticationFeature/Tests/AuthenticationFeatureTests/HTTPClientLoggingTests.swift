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

    /// A response runs on every request in the app, so it records at the level the platform drops
    /// unless someone is watching.
    @Test func whenResponseArrives_shouldLogAtDebugLevel() async throws {
        let event = try #require(try await arrival(URLRequest(url: url), statusCode: 200))

        #expect(event.level == .debug)
    }

    /// A 500 reached us, so nothing about the transport failed. This seam records the status it saw
    /// and leaves whoever reads the response to judge it.
    @Test func whenServerRespondsWithErrorStatus_shouldLogStatusWithoutRaisingLevel() async throws {
        let event = try #require(try await arrival(URLRequest(url: url), statusCode: 500))

        #expect(event.level == .debug)
        #expect(event.fields.first { String($0.name) == "statusCode" }?.value == .integer(500))
    }

    @Test func whenResponseArrives_shouldLogMethodAndPath() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let event = try #require(try await arrival(request, statusCode: 200))

        let logged = try #require(event.fields.first { String($0.name) == "request" })
        #expect(logged.value == .string("POST /api/v1/login/ticket"))
    }

    /// The same rule as the failure path: a query can carry credentials, so it never reaches the log.
    @Test func whenResponseArrives_shouldNotLogQuery() async throws {
        let event = try #require(try await arrival(URLRequest(url: url), statusCode: 200))

        let logged = try #require(event.fields.first { String($0.name) == "request" })
        #expect(logged.value == .string("GET /api/v1/login/ticket"))
    }

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let arrived = try #require(try await arrival(URLRequest(url: url), statusCode: 200))
        let failed = try #require(await attempt(URLRequest(url: url)))

        #expect(arrived.message != failed.message)
    }

    private func arrival(_ request: URLRequest, statusCode: Int) async throws -> LogEvent? {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = HTTPClient.responding(with: Data(), statusCode: statusCode).logging()
            return try await sut.send(request)
        }

        return recorder.events.first
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
