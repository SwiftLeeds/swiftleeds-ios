import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

/// The public `AttendeeFetchError` is deliberately bare, so these assert the reason survives to the
/// log even though the caller never sees it.
@Suite struct AttendeeMapperLoggingTests {
    private let url = "https://example.com/api/v1/login/ticket"

    @Test func whenResponseIsInvalid_shouldLogAtErrorLevel() throws {
        let event = try #require(try logEvent(forBody: attendeeJSON(reference: "!!!")))

        #expect(event.level == .error)
    }

    @Test func whenFieldIsMissing_shouldLogFieldPath() throws {
        let missingLastName = Data(#"{"ticket": {"first_name": "Ada"}}"#.utf8)

        let event = try #require(try logEvent(forBody: missingLastName))

        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("keyNotFound ticket.last_name"))
    }

    @Test func whenSessionIsNotAuthorised_shouldLogAtNoticeRatherThanError() throws {
        let event = try #require(try logEvent(statusCode: 401))

        #expect(event.level == .notice)
    }

    @Test func whenServerReturnsUnexpectedStatus_shouldLogStatusCode() throws {
        let event = try #require(try logEvent(statusCode: 503))

        #expect(event.level == .error)
        #expect(event.fields.first { String($0.name) == "statusCode" }?.value == .integer(503))
    }

    @Test func whenEmailIsInvalid_shouldLogEmailField() throws {
        let event = try #require(try logEvent(forBody: attendeeJSON(email: "")))

        #expect(event.fields.first { String($0.name) == "field" }?.value == .string("email"))
    }

    @Test func whenReferenceIsInvalid_shouldLogReferenceField() throws {
        let event = try #require(try logEvent(forBody: attendeeJSON(reference: "!!!")))

        #expect(event.fields.first { String($0.name) == "field" }?.value == .string("reference"))
    }

    @Test func whenBodyIsNotJSON_shouldLogDifferentMessageThanInvalidField() throws {
        let malformed = try #require(try logEvent(forBody: Data("not json".utf8)))
        let invalidField = try #require(try logEvent(forBody: attendeeJSON(reference: "!!!")))

        #expect(malformed.message != invalidField.message)
    }

    /// A destination groups by message, so two causes sharing one message could never be told apart
    /// when filtering.
    @Test func whenCausesDiffer_shouldLogDifferentMessages() throws {
        let unreadable = try #require(try logEvent(forBody: attendeeJSON(reference: "!!!")))
        let unauthorised = try #require(try logEvent(statusCode: 401))
        let unexpected = try #require(try logEvent(statusCode: 503))

        #expect(unreadable.message != unauthorised.message)
        #expect(unauthorised.message != unexpected.message)
        #expect(unexpected.message != unreadable.message)
    }

    @Test func whenResponseIsRejected_shouldRethrowResponseError() throws {
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 503)

        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = AttendeeMapper.live.loggingFailures()

            #expect(throws: AttendeeMapper.ResponseError.self) {
                try sut.map(Data(), response)
            }
        }
    }

    @Test func whenResponseIsValid_shouldLogNothing() throws {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 200)

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.loggingFailures()
            _ = try sut.map(attendeeJSON(), response)
        }

        #expect(recorder.events.isEmpty)
    }

    private func logEvent(forBody data: Data = Data(), statusCode: Int = 200) throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: statusCode)

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.loggingFailures()
            _ = try? sut.map(data, response)
        }

        return recorder.events.first
    }
}
