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

    /// Foundation attaches the failing URL to a `URLError`, query and all, so the reason field has
    /// to name the code rather than describe the error.
    @Test func whenTransportFails_shouldNotLogQueryThroughTheReason() async throws {
        let offline = URLError(
            .notConnectedToInternet,
            userInfo: [NSURLErrorFailingURLStringErrorKey: String(describing: url)]
        )

        let event = try #require(await attempt(URLRequest(url: url), failingWith: offline))

        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("notConnectedToInternet"))
    }

    /// An offline device is expected and the user can retry, which is the level the outcome seams
    /// already give it.
    @Test func whenDeviceIsOffline_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(
            await attempt(URLRequest(url: url), failingWith: URLError(.notConnectedToInternet))
        )

        #expect(event.level == .notice)
    }

    /// Leaving a screen while it loads cancels the task. That is control flow, not a failure to
    /// report.
    @Test func whenRequestIsCancelled_shouldLogAtDebugRatherThanError() async throws {
        let event = try #require(
            await attempt(URLRequest(url: url), failingWith: URLError(.cancelled))
        )

        #expect(event.level == .debug)
    }

    @Test func whenServerCertificateIsUntrusted_shouldLogAtErrorLevel() async throws {
        let event = try #require(
            await attempt(URLRequest(url: url), failingWith: URLError(.serverCertificateUntrusted))
        )

        #expect(event.level == .error)
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

        #expect(recorder.events.count == 1)
        return recorder.events.first
    }

    private func attempt(
        _ request: URLRequest,
        failingWith error: some Error & Sendable = StubFailure.couldNotBuildResponse
    ) async -> LogEvent? {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = HTTPClient.failing(with: error).logging()
            _ = try await sut.send(request)
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
