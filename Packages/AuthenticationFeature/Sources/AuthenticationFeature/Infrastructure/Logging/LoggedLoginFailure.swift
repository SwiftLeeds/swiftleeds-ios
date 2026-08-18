import LogKit

/// How a login failure reads in a log.
///
/// A mapped projection, in the same spirit as `CachedSession` for storage: the failure types stay
/// free of LogKit, and every decision about how they are recorded lives here. Each failure gets its
/// own message, because a message is what a destination groups and filters by; one shared message
/// with the cause in a field cannot be filtered at all.
struct LoggedLoginFailure {
    let level: LogLevel
    let message: LogMessage

    init(_ failure: LoginRequestFailure) {
        switch failure {
        case let .couldNotEncodeRequest(cause):
            level = .error
            message = "The sign-in request could not be encoded: \(cause, name: "reason", privacy: .open)"
        case let .transportFailed(cause):
            level = .error
            message = "The sign-in request could not reach the server: \(cause, name: "reason", privacy: .open)"
        }
    }

    init(_ failure: LoginResponseFailure) {
        switch failure {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            level = .notice
            message = "The sign-in credentials were rejected"
        case let .unexpectedStatus(code):
            level = .error
            message = "Sign-in got an unexpected status \(code, name: "statusCode", privacy: .open)"
        }
    }
}
