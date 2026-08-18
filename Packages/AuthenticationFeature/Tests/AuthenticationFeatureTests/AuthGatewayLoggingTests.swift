import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

/// The public `SignInError` is deliberately bare, so these assert the reason survives to the
/// log even though the caller never sees it.
@Suite struct AuthGatewayLoggingTests {
    @Test func whenCredentialsAreRejected_shouldSayTheyWereRejected() async throws {
        let event = try #require(await attempt(statusCode: 401))

        #expect(event.message == "The sign-in credentials were rejected")
    }

    /// A mistyped ticket reference is an expected outcome, not a fault in the app.
    @Test func whenCredentialsAreRejected_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await attempt(statusCode: 401))

        #expect(event.level == .notice)
    }

    @Test func whenServerReturnsUnexpectedStatus_shouldLogTheStatus() async throws {
        let event = try #require(await attempt(statusCode: 503))

        #expect(event.level == .error)
        #expect(event.fields.first { String($0.name) == "statusCode" }?.value == .integer(503))
    }

    @Test func whenTransportFails_shouldLogTheCause() async throws {
        let event = try #require(await attempt(failingWith: StubFailure.couldNotBuildResponse))

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    /// The point of a projection per failure: a destination groups by message, so two causes sharing
    /// one message could never be told apart when filtering.
    @Test func whenCausesDiffer_shouldLogDifferentMessages() async throws {
        let rejected = try #require(await attempt(statusCode: 401))
        let unexpected = try #require(await attempt(statusCode: 503))
        let transport = try #require(await attempt(failingWith: StubFailure.couldNotBuildResponse))

        #expect(rejected.message != unexpected.message)
        #expect(unexpected.message != transport.message)
        #expect(transport.message != rejected.message)
    }

    @Test func whenTransportFailsAndResponseIsFine_shouldLogOnlyOnce() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .responding(with: Data(), statusCode: 503)
            $0.log = recorder.log
        } operation: {
            _ = try await AuthGateway.liveValue.authenticate(credential())
        }

        #expect(recorder.events.count == 1)
    }

    @Test func whenServerReturnsToken_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.httpClient = .responding(with: Data("jwt-abc-123".utf8), statusCode: 200)
            $0.log = recorder.log
        } operation: {
            try await AuthGateway.liveValue.authenticate(credential())
        }

        #expect(recorder.events.isEmpty)
    }
}

private func attempt(statusCode: Int) async -> LogEvent? {
    let recorder = LogRecorder()

    try? await withDependencies {
        $0.httpClient = .responding(with: Data(), statusCode: statusCode)
        $0.log = recorder.log
    } operation: {
        _ = try await AuthGateway.liveValue.authenticate(credential())
    }

    return recorder.events.first
}

private func attempt(failingWith error: some Error & Sendable) async -> LogEvent? {
    let recorder = LogRecorder()

    try? await withDependencies {
        $0.httpClient = .failing(with: error)
        $0.log = recorder.log
    } operation: {
        _ = try await AuthGateway.liveValue.authenticate(credential())
    }

    return recorder.events.first
}

private func credential() throws -> Credential {
    try Credential(
        email: EmailAddress("attendee@example.com"),
        ticketReference: TicketReference("ABCD-12")
    )
}
