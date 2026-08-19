import LogKit

/// How an attendee-fetch failure reads in a log.
struct LoggedAttendeeFetchError {
    let level: LogLevel
    let message: LogMessage

    init(_ error: AttendeeMapper.ResponseError) {
        switch error {
        case let .couldNotRead(cause):
            level = .error
            message = "The attendee response could not be read: \(cause, name: "reason", privacy: .open)"
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            level = .notice
            message = "The attendee request was not authorised"
        case let .unexpectedStatus(code):
            level = .error
            message = "The attendee request got an unexpected status \(code, name: "statusCode", privacy: .open)"
        }
    }
}
