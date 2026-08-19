import AuthenticationFeature
import Dependencies
import Foundation
import LogKit
import Testing

/// The public `AttendeeFetchError` is deliberately bare, so these assert the reason survives to the
/// log even though the caller never sees it.
@Suite struct AttendeeMapperLoggingTests {
    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://example.com/api/v1/login/ticket"))
    }

    @Test func whenResponseIsInvalid_shouldLogAtErrorLevel() throws {
        let event = try #require(try logEvent(forResponse: attendeeJSON(reference: "!!!")))

        #expect(event.level == .error)
    }

    @Test func whenFieldIsMissing_shouldLogFieldPath() throws {
        let missingLastName = Data(#"{"ticket": {"first_name": "Ada"}}"#.utf8)

        let event = try #require(try logEvent(forResponse: missingLastName))

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

    /// A destination groups by message, so two causes sharing one message could never be told apart
    /// when filtering.
    @Test func whenCausesDiffer_shouldLogDifferentMessages() throws {
        let unreadable = try #require(try logEvent(forResponse: attendeeJSON(reference: "!!!")))
        let unauthorised = try #require(try logEvent(statusCode: 401))
        let unexpected = try #require(try logEvent(statusCode: 503))

        #expect(unreadable.message != unauthorised.message)
        #expect(unauthorised.message != unexpected.message)
        #expect(unexpected.message != unreadable.message)
    }

    @Test func whenResponseIsRejected_shouldRethrowResponseError() throws {
        let response = try response(statusCode: 503)

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
        let response = try response(statusCode: 200)

        try withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.loggingFailures()
            _ = try sut.map(attendeeJSON(), response)
        }

        #expect(recorder.events.isEmpty)
    }

    private func logEvent(forResponse data: Data = Data(), statusCode: Int = 200) throws -> LogEvent? {
        let recorder = LogRecorder()
        let response = try response(statusCode: statusCode)

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeMapper.live.loggingFailures()
            _ = try? sut.map(data, response)
        }

        return recorder.events.first
    }

    private func response(statusCode: Int) throws -> HTTPURLResponse {
        try #require(
            HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        )
    }
}
