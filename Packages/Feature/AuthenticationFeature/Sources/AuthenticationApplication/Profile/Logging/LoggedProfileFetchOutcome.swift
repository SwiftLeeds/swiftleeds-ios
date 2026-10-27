import AuthenticationDomain
import LogKit

/// How the outcome of a profile fetch reads in a log.
struct LoggedProfileFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    /// The outcome of a profile fetch that succeeded.
    static let success = Self(
        level: .info,
        message: "The profile loaded",
    )

    static func failure(_ error: AttendeeFetchError) -> Self {
        switch error {
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            Self(
                level: .notice,
                message: "Loading the profile did not finish: the session was not accepted",
            )

        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            Self(
                level: .notice,
                message: "Loading the profile did not finish: the server could not be reached",
            )

        case .invalidResponse:
            Self(
                level: .error,
                message: "Loading the profile did not finish: the server's answer was rejected",
            )

        case .unknown:
            Self(
                level: .error,
                message: "Loading the profile did not finish: the reason is not known",
            )
        }
    }
}
