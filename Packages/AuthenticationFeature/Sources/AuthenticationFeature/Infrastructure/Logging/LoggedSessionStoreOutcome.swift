import LogKit

/// How each thing the session store did reads in a log.
struct LoggedSessionStoreOutcome {
    let level: LogLevel
    let message: LogMessage

    static let stored = LoggedSessionStoreOutcome(
        level: .info,
        message: "The session was stored"
    )

    static let cleared = LoggedSessionStoreOutcome(
        level: .info,
        message: "The session was cleared"
    )

    /// A read runs on every authenticated request, so it records at the level the platform drops
    /// unless someone is watching. Finding nothing gets its own message, because that is the line
    /// that explains why a user is signed out.
    static func read(foundSession: Bool) -> LoggedSessionStoreOutcome {
        LoggedSessionStoreOutcome(
            level: .debug,
            message: foundSession ? "The stored session was read" : "No session is stored"
        )
    }

    static func notStored(_ error: any Error) -> LoggedSessionStoreOutcome {
        LoggedSessionStoreOutcome(
            level: .error,
            message: "The session could not be stored: \(error, name: "reason", privacy: .open)"
        )
    }

    static func notCleared(_ error: any Error) -> LoggedSessionStoreOutcome {
        LoggedSessionStoreOutcome(
            level: .error,
            message: "The session could not be cleared: \(error, name: "reason", privacy: .open)"
        )
    }

    static func notRead(_ error: any Error) -> LoggedSessionStoreOutcome {
        LoggedSessionStoreOutcome(
            level: .error,
            message: "The stored session could not be read: \(error, name: "reason", privacy: .open)"
        )
    }
}
