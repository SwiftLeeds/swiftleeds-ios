import LogKit
import NetworkKit

struct LoggedAttendeeResponseOutcome {
    let level: LogLevel
    let message: LogMessage

    // Carries no field. The accepted value holds a name, an email address and a ticket reference.
    static let success = Self(
        level: .debug,
        message: "The attendee response was accepted",
    )

    static func failure(_ error: AttendeeMapper.ResponseError) -> Self {
        switch error {
        case let .couldNotDecode(cause):
            Self(
                level: .error,
                message: "The attendee response could not be decoded: \(cause, name: "reason", privacy: .open)",
            )
        case let .invalidField(invalid):
            Self(
                level: .error,
                message: """
                    The attendee response had an invalid \(invalid.field.rawValue, name: "field", privacy: .open): \
                    \(invalid.reason, name: "reason", privacy: .open)
                    """,
            )
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            Self(
                level: .notice,
                message: "The attendee request was not authorized",
            )
        case let .unexpectedStatus(status):
            Self(
                level: .error,
                message: """
                    The attendee request got an unexpected status \
                    \(Int(status.code), name: "statusCode", privacy: .open) \
                    (\(String(status.category), name: "statusCategory", privacy: .open))
                    """,
            )
        }
    }
}
