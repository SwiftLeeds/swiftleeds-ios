import LogKit

/// How the outcome of sending a sign-in request reads in a log.
struct LoggedLoginRequestOutcome {
    let level: LogLevel
    let message: LogMessage

    /// Carries no field. The credential is an email address and a ticket reference, and both
    /// identify a person.
    static let success = LoggedLoginRequestOutcome(
        level: .debug,
        message: "The server accepted the sign-in credentials"
    )

    /// Returns `nil` for a transport failure, which the decorator on `HTTPClient` already recorded.
    static func failure(_ error: LoginRequestError) -> LoggedLoginRequestOutcome? {
        switch error {
        case let .couldNotEncodeRequest(cause):
            LoggedLoginRequestOutcome(
                level: .error,
                message: "The sign-in request could not be encoded: \(cause, name: "reason", privacy: .open)"
            )
        case .transportFailed:
            nil
        }
    }
}
