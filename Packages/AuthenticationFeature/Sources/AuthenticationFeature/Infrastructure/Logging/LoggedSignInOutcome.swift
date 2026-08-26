import LogKit

/// How the outcome of a sign-in reads in a log.
struct LoggedSignInOutcome {
    let level: LogLevel
    let message: LogMessage

    init(_ error: SignInError) {
        switch error {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            level = .notice
            message = "Signing in did not finish: the credentials were rejected"
        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            level = .notice
            message = "Signing in did not finish: the server could not be reached"
        case .unknown:
            level = .error
            message = "Signing in did not finish: the reason is not known"
        }
    }
}
