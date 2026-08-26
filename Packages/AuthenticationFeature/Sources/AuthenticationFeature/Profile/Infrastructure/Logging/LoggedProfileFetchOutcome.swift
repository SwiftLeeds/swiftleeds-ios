import LogKit

/// How the outcome of a profile fetch reads in a log.
struct LoggedProfileFetchOutcome {
    let level: LogLevel
    let message: LogMessage

    /// Carries no field. A profile holds a name, an email address and a ticket reference, and none
    /// of them belong in a log line that says the load worked.
    static let success = LoggedProfileFetchOutcome(
        level: .info,
        message: "The profile loaded"
    )

    static func failure(_ error: AttendeeFetchError) -> LoggedProfileFetchOutcome {
        switch error {
        case .unauthorized:
            // Expected: the session expired or was revoked. Not a fault in the app.
            LoggedProfileFetchOutcome(
                level: .notice,
                message: "Loading the profile did not finish: the session was not accepted"
            )
        case .couldNotReachServer:
            // Expected: the device is offline. The user can retry.
            LoggedProfileFetchOutcome(
                level: .notice,
                message: "Loading the profile did not finish: the server could not be reached"
            )
        case .invalidResponse:
            LoggedProfileFetchOutcome(
                level: .error,
                message: "Loading the profile did not finish: the server's answer was rejected"
            )
        case .unknown:
            LoggedProfileFetchOutcome(
                level: .error,
                message: "Loading the profile did not finish: the reason is not known"
            )
        }
    }
}
