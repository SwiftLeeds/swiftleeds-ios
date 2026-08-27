import LogKit

struct LoggedLoginResponseOutcome {
    let level: LogLevel
    let message: LogMessage

    // Carries no field. The accepted value is a session token, and nothing about it belongs in a
    // log line saying the response parsed.
    static let success = LoggedLoginResponseOutcome(
        level: .debug,
        message: "The sign-in response was accepted"
    )

    static func failure(_ error: LoginMapper.ResponseError) -> LoggedLoginResponseOutcome {
        switch error {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            LoggedLoginResponseOutcome(
                level: .notice,
                message: "The sign-in credentials were rejected"
            )
        case let .unexpectedStatus(status):
            LoggedLoginResponseOutcome(
                level: .error,
                message: "Sign-in got an unexpected status \(Int(status), name: "statusCode", privacy: .open)"
            )
        case let .invalidToken(reason):
            LoggedLoginResponseOutcome(
                level: .error,
                message: "The server's sign-in token was rejected: \(reason, name: "reason", privacy: .open)"
            )
        }
    }
}
