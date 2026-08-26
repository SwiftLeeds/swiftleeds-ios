import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

/// The public `SignInError` is deliberately bare, so these assert the reason survives to the log
/// even though the caller never sees it.
@Suite struct LoginMapperLoggingTests {
    private let url = "https://example.com/api/v1/login/ticket"

    @Test func whenCredentialsAreRejected_shouldSayCredentialsWereRejected() throws {
        let event = try #require(try logEvent(statusCode: 401))

        #expect(event.message == "The sign-in credentials were rejected")
    }

    @Test func whenCredentialsAreRejected_shouldLogAtNoticeRatherThanError() throws {
        let event = try #require(try logEvent(statusCode: 401))

        #expect(event.level == .notice)
    }

    @Test func whenServerReturnsUnexpectedStatus_shouldLogStatusCode() throws {
        let event = try #require(try logEvent(statusCode: 503))

        #expect(event.level == .error)
        #expect(event.fields.first { String($0.name) == "statusCode" }?.value == .integer(503))
    }

    @Test func whenTokenIsBlank_shouldLogRejectionReason() throws {
        let event = try #require(try logEvent(forBody: Data("   ".utf8)))

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("empty"))
    }

    @Test func whenResponseIsRejected_shouldRethrowResponseError() throws {
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 503)

        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = LoginMapper.live.logging()

            #expect(throws: LoginMapper.ResponseError.self) {
                try sut.map(Data(), response)
            }
        }
    }

    /// A response is accepted on every sign-in attempt that works, so it records at the level the
    /// platform drops unless someone is watching.
    @Test func whenServerReturnsToken_shouldLogAtDebugLevel() throws {
        let event = try #require(try acceptedEvent())

        #expect(event.level == .debug)
    }

    /// The accepted value is a session token. Nothing about it belongs in a log line.
    @Test func whenServerReturnsToken_shouldLogNoToken() throws {
        let event = try #require(try acceptedEvent())

        #expect(event.fields.isEmpty)
    }

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() throws {
        let messages = try [
            #require(try acceptedEvent()),
            #require(try logEvent(statusCode: 401)),
            #require(try logEvent(statusCode: 503)),
            #require(try logEvent(forBody: Data("   ".utf8))),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    private func acceptedEvent() throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 200)

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = LoginMapper.live.logging()
            _ = try sut.map(Data("jwt-abc-123".utf8), response)
        }

        return recorder.events.first
    }

    private func logEvent(forBody data: Data = Data(), statusCode: Int = 200) throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: statusCode)

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = LoginMapper.live.logging()
            _ = try? sut.map(data, response)
        }

        return recorder.events.first
    }
}
