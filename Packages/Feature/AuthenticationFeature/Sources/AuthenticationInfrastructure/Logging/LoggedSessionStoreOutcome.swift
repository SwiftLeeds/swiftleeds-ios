import LogKit

/// How each thing the session store did reads in a log.
struct LoggedSessionStoreOutcome {
    let level: LogLevel
    let message: LogMessage

    static let stored = Self(
        level: .info,
        message: "The session was stored",
    )

    static let cleared = Self(
        level: .info,
        message: "The session was cleared",
    )

    /// Returns the outcome of reading the stored session.
    ///
    /// A read runs on every authenticated request, so it records at the level the platform drops
    /// unless someone is watching. Finding nothing gets its own message, because that is the line
    /// that explains why a user is signed out.
    ///
    /// - Parameter foundSession: Whether the store held a session.
    /// - Returns: The outcome to log for the read.
    static func read(foundSession: Bool) -> Self {
        Self(
            level: .debug,
            message: foundSession ? "The stored session was read" : "No session is stored",
        )
    }

    static func notStored(_ error: any Error) -> Self {
        Self(
            level: .error,
            message: "The session could not be stored: \(error, name: "reason", privacy: .open)",
        )
    }

    static func notCleared(_ error: any Error) -> Self {
        Self(
            level: .error,
            message: "The session could not be cleared: \(error, name: "reason", privacy: .open)",
        )
    }

    static func notRead(_ error: any Error) -> Self {
        Self(
            level: .error,
            message: "The stored session could not be read: \(error, name: "reason", privacy: .open)",
        )
    }
}
