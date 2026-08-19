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

    @Test func whenGatewaySucceeds_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AuthGateway { _ in try SessionToken("jwt-abc-123") }.loggingRequestFailures()
            return try await sut.authenticate(Credential.fixture)
        }

        #expect(recorder.events.isEmpty)
    }
}

private func logEvent(forFailure error: LoginRequestError) async -> LogEvent? {
    let recorder = LogRecorder()

    try? await withDependencies {
        $0.log = recorder.log
    } operation: {
        let sut = AuthGateway { _ in throw error }.loggingRequestFailures()
        _ = try await sut.authenticate(Credential.fixture)
    }

    return recorder.events.first
}
