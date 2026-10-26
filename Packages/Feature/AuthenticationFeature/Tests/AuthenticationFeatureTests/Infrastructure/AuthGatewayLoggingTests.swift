import AuthenticationDomain
import AuthenticationInfrastructure
import Dependencies
import LogKit
import LogKitTestSupport
import Testing

@Suite struct AuthGatewayLoggingTests {
    /// An error the stubbed gateway's failure wraps.
    private enum CauseStubError: Error {
        /// The wrapped operation failed.
        case failed
    }

    @Test func whenRequestCannotBeEncoded_shouldLogReason() async throws {
        let failure = LoginRequestError.couldNotEncodeRequest(CauseStubError.failed)

        let event = try #require(await logEvent(forFailure: failure))

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("failed"))
    }

    /// A filter on the network category must find every line the gateway writes.
    @Test func whenAnyOutcomeIsLogged_shouldLogUnderAuthNetworkCategory() async {
        let events = [
            await logEvent(
                forFailure: LoginRequestError.couldNotEncodeRequest(CauseStubError.failed)
            ),
            await logEvent(
                forFailure: LoginRequestError.transportFailed(CauseStubError.failed)
            ),
        ].compactMap(\.self)

        #expect(events.count == 1)
        #expect(events.allSatisfy { $0.category == "authNetwork" })
    }

    /// Transport failures are logged once, by the decorator on `HTTPClient`.
    @Test func whenTransportFails_shouldLogNothing() async {
        let failure = LoginRequestError.transportFailed(CauseStubError.failed)

        let event = await logEvent(forFailure: failure)

        #expect(event == nil)
    }

    /// The gateway returns what the mapper handed back, and `LoginMapperLoggingTests` pins that the
    /// mapper records it. A line here would repeat it.
    @Test func whenGatewaySucceeds_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AuthGateway { _ in try SessionToken("jwt-abc-123") }.logging()
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
        let sut = AuthGateway { _ in throw error }.logging()
        _ = try await sut.authenticate(Credential.fixture)
    }

    return recorder.events.first
}
