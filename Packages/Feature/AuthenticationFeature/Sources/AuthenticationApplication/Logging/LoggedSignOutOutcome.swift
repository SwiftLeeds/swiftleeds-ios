import LogKit

/// How the outcome of a sign-out reads in a log.
struct LoggedSignOutOutcome {
    let level: LogLevel
    let message: LogMessage

    static let success = Self(
        level: .notice,
        message: "Signing out finished",
    )

    static let failure = Self(
        level: .error,
        message: "Signing out did not finish, so the session is still on this device",
    )
}
