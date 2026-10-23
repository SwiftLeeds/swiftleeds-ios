import AuthenticationDomain
import LogKit

/// How the outcome of a sign-in reads in a log.
struct LoggedSignInOutcome {
    let level: LogLevel
    let message: LogMessage

    /// Carries no field. The credential identifies a person, and nothing here needs it.
    static let success = Self(
        level: .notice,
        message: "Signing in finished",
    )

    /// A failure that is not a `SignInError`.
    static let unexplainedFailure = Self(
        level: .error,
        message: "Signing in did not finish, and no sign-in outcome explains it",
    )

    static func failure(_ error: SignInError) -> Self {
        switch error {
        case .invalidCredentials:
            // Expected: someone mistyped a ticket reference. Not a fault in the app.
            Self(
                level: .notice,
                message: "Signing in did not finish: the credentials were rejected",
            )

        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            Self(
                level: .notice,
                message: "Signing in did not finish: the server could not be reached",
            )

        case .unknown:
            Self(
                level: .error,
                message: "Signing in did not finish: the reason is not known",
            )
        }
    }
}
