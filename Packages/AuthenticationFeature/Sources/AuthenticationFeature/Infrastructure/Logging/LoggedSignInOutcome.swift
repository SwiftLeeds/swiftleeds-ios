import LogKit

/// How the outcome of a sign-in reads in a log.
struct LoggedSignInOutcome {
    let level: LogLevel
    let message: LogMessage

    /// Carries no field. The credential identifies a person, and nothing here needs it.
    static let success = LoggedSignInOutcome(
        level: .notice,
        message: "Signing in finished"
    )

    /// The gateway throws only ``SignInError``, so in the live app this is the session store. The
    /// message names no step: `narrowingFailures()` has no catch-all, so a third error type would
    /// reach here without the store ever running.
    static let unexplainedFailure = LoggedSignInOutcome(
        level: .error,
        message: "Signing in did not finish, and no sign-in outcome explains it"
    )

    static func failure(_ error: SignInError) -> LoggedSignInOutcome {
        switch error {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            LoggedSignInOutcome(
                level: .notice,
                message: "Signing in did not finish: the credentials were rejected"
            )
        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            LoggedSignInOutcome(
                level: .notice,
                message: "Signing in did not finish: the server could not be reached"
            )
        case .unknown:
            LoggedSignInOutcome(
                level: .error,
                message: "Signing in did not finish: the reason is not known"
            )
        }
    }
}
