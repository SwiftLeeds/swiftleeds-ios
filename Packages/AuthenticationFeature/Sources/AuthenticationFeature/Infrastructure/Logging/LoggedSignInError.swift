import LogKit

/// How a sign-in failure reads in a log.
struct LoggedSignInError {
    let level: LogLevel
    let message: LogMessage

    init?(_ error: LoginRequestError) {
        switch error {
        case let .couldNotEncodeRequest(cause):
            level = .error
            message = "The sign-in request could not be encoded: \(cause, name: "reason", privacy: .open)"
        case .transportFailed:
            // Already logged once, at the transport seam.
            return nil
        }
    }

    init(_ error: LoginMapper.ResponseError) {
        switch error {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            level = .notice
            message = "The sign-in credentials were rejected"
        case let .unexpectedStatus(code):
            level = .error
            message = "Sign-in got an unexpected status \(code, name: "statusCode", privacy: .open)"
        case let .invalidToken(reason):
            level = .error
            message = "The server's sign-in token was rejected: \(reason, name: "reason", privacy: .open)"
        }
    }
}
