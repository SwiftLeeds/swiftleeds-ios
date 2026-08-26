import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

@Suite struct AuthGatewayLoggingTests {
    @Test func whenRequestCannotBeEncoded_shouldLogReason() async throws {
        let failure = LoginRequestError.couldNotEncodeRequest(StubFailure.couldNotBuildResponse)

        let event = try #require(await logEvent(forFailure: failure))

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    /// Transport failures are logged once, by the decorator on `HTTPClient`.
    @Test func whenTransportFails_shouldLogNothing() async throws {
        let failure = LoginRequestError.transportFailed(StubFailure.couldNotBuildResponse)

        let event = await logEvent(forFailure: failure)

        #expect(event == nil)
    }

    /// This line marks the boundary between a parsed response and a stored session, so a failure
    /// between the two is not an unexplained gap.
    @Test func whenGatewaySucceeds_shouldLogAtDebugLevel() async throws {
        let event = try #require(try await acceptedEvent())

        #expect(event.level == .debug)
    }

    /// The credential is an email address and a ticket reference. Neither belongs in a log line.
    @Test func whenGatewaySucceeds_shouldLogNoCredential() async throws {
        let event = try #require(try await acceptedEvent())

        #expect(event.fields.isEmpty)
    }

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let failure = LoginRequestError.couldNotEncodeRequest(StubFailure.couldNotBuildResponse)

        let accepted = try #require(try await acceptedEvent())
        let refused = try #require(await logEvent(forFailure: failure))

        #expect(accepted.message != refused.message)
    }
}

private func acceptedEvent() async throws -> LogEvent? {
    let recorder = LogRecorder()

    _ = try await withDependencies {
        $0.log = recorder.log
    } operation: {
        let sut = AuthGateway { _ in try SessionToken("jwt-abc-123") }.logging()
        return try await sut.authenticate(Credential.fixture)
    }

    return recorder.events.first
}

private func logEvent(forFailure error: LoginRequestError) async -> LogEvent? {
    let recorder = LogRecorder()

    try? await withDependencies {
        $0.log = recorder.log
    } operation: {
        let sut = AuthGateway { _ in throw error }.logging()
        _ = try await sut.authenticate(Credential.fixture)
    }

    return recorder.events.first
}
