import Dependencies
import LogKit

extension SessionStore {
    /// Records what the store did, then returns or rethrows.
    ///
    /// Every caller discards the error with `try?`, so a refusal reaches no one else. A session that
    /// will not clear stays on the device after the user believes they signed out.
    package func logging() -> SessionStore {
        SessionStore(
            establish: { session in
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                do {
                    try await establish(session)
                    let entry = LoggedSessionStoreOutcome.stored
                    log(entry.level, .auth, entry.message)
                } catch {
                    let entry = LoggedSessionStoreOutcome.notStored(error)
                    log(entry.level, .auth, entry.message)
                    throw error
                }
            },
            clear: {
                @Dependency(\.log) var log
                do {
                    try await clear()
                    let entry = LoggedSessionStoreOutcome.cleared
                    log(entry.level, .auth, entry.message)
                } catch {
                    let entry = LoggedSessionStoreOutcome.notCleared(error)
                    log(entry.level, .auth, entry.message)
                    throw error
                }
            },
            current: {
                @Dependency(\.log) var log
                do {
                    let session = try await current()
                    let entry = LoggedSessionStoreOutcome.read(foundSession: session != nil)
                    log(entry.level, .auth, entry.message)
                    return session
                } catch {
                    let entry = LoggedSessionStoreOutcome.notRead(error)
                    log(entry.level, .auth, entry.message)
                    throw error
                }
            }
        )
    }
}
