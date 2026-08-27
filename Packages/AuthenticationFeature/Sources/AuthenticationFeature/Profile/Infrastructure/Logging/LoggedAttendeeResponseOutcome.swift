import LogKit

struct LoggedAttendeeResponseOutcome {
    let level: LogLevel
    let message: LogMessage

    // Carries no field. The accepted value holds a name, an email address and a ticket reference.
    static let success = LoggedAttendeeResponseOutcome(
        level: .debug,
        message: "The attendee response was accepted"
    )

    static func failure(_ error: AttendeeMapper.ResponseError) -> LoggedAttendeeResponseOutcome {
        switch error {
        case let .couldNotDecode(cause):
            LoggedAttendeeResponseOutcome(
                level: .error,
                message: "The attendee response could not be decoded: \(cause, name: "reason", privacy: .open)"
            )
        case let .invalidField(invalid):
            LoggedAttendeeResponseOutcome(
                level: .error,
                message: """
                The attendee response had an invalid \(invalid.field.rawValue, name: "field", privacy: .open): \
                \(invalid.reason, name: "reason", privacy: .open)
                """
            )
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            LoggedAttendeeResponseOutcome(
                level: .notice,
                message: "The attendee request was not authorized"
            )
        case let .unexpectedStatus(status):
            LoggedAttendeeResponseOutcome(
                level: .error,
                message: """
                The attendee request got an unexpected status \
                \(Int(status.code), name: "statusCode", privacy: .open)
                """
            )
        }
    }
}
