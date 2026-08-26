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

    @Test func whenResponseIsRejected_shouldRethrowResponseError() throws {
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 503)

        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = AttendeeMapper.live.logging()

            #expect(throws: AttendeeMapper.ResponseError.self) {
                try sut.map(Data(), response)
            }
        }
    }

    /// A response is accepted every time the profile card loads, so it records at the level the
    /// platform drops unless someone is watching.
    @Test func whenResponseIsValid_shouldLogAtDebugLevel() throws {
        let event = try #require(try acceptedEvent())

        #expect(event.level == .debug)
    }

    /// The accepted value holds a name, an email address and a ticket reference. None of them
    /// belong in a log line saying the response parsed.
    @Test func whenResponseIsValid_shouldLogNoAttendeeDetail() throws {
        let event = try #require(try acceptedEvent())

        #expect(event.fields.isEmpty)
    }

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() throws {
        let messages = try [
            #require(try acceptedEvent()),
            #require(try logEvent(forBody: attendeeJSON(reference: "!!!"))),
            #require(try logEvent(forBody: Data("not json".utf8))),
            #require(try logEvent(statusCode: 401)),
            #require(try logEvent(statusCode: 503)),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    private func acceptedEvent() throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: 200)

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.logging()
            _ = try sut.map(attendeeJSON(), response)
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }

    private func logEvent(forBody data: Data = Data(), statusCode: Int = 200) throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try HTTPURLResponse.fixture(url: url, statusCode: statusCode)

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.logging()
            _ = try? sut.map(data, response)
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
