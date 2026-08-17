import AuthenticationFeature
import Dependencies
import Foundation
import Testing

/// The public `AuthenticationError` is deliberately bare, so these assert the reason survives to the
/// log even though the caller never sees it.
@Suite struct AuthGatewayLoggingTests {
    @Test func whenServerReturnsUnexpectedStatus_shouldLogTheStatus() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .responding(with: Data(), statusCode: 503)
            $0.log = recorder.log
        } operation: {
            _ = try await AuthGateway.liveValue.authenticate(credential())
        }

        let reason = try #require(recorder.events.first?.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("unexpectedStatus(503)"))
    }

    @Test func whenCredentialsAreRejected_shouldLogThatReason() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .responding(with: Data(), statusCode: 401)
            $0.log = recorder.log
        } operation: {
            _ = try await AuthGateway.liveValue.authenticate(credential())
        }

        let reason = try #require(recorder.events.first?.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("invalidCredentials"))
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

    /// A rejected credential is an expected outcome, not a fault in the app.
    @Test func whenCredentialsAreRejected_shouldLogAtNoticeRatherThanError() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .responding(with: Data(), statusCode: 401)
            $0.log = recorder.log
        } operation: {
            _ = try await AuthGateway.liveValue.authenticate(credential())
        }

        #expect(recorder.events.map(\.level) == [.notice])
    }
}

private func credential() throws -> Credential {
    try Credential(
        email: EmailAddress("attendee@example.com"),
        ticketReference: TicketReference("ABCD-12")
    )
}
