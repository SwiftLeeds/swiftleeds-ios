import Dependencies
import LogKit

extension SessionStore {
    /// Records why the store refused, then rethrows.
    ///
    /// A session that will not clear stays on the device after the user believes they signed out.
    package func logging() -> SessionStore {
        SessionStore(
            establish: { session in
                do {
                    try await establish(session)
                } catch {
                    // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                    // building liveValue would capture whichever log existed first.
                    @Dependency(\.log) var log
                    log.error(
                        "The session could not be stored: \(error, name: "reason", privacy: .open)",
                        in: .auth
                    )
                    throw error
                }
            },
            clear: {
                do {
                    try await clear()
                } catch {
                    @Dependency(\.log) var log
                    log.error(
                        "The session could not be cleared: \(error, name: "reason", privacy: .open)",
                        in: .auth
                    )
                    throw error
                }
            },
            current: {
                do {
                    return try await current()
                } catch {
                    @Dependency(\.log) var log
                    log.error(
                        "The stored session could not be read: \(error, name: "reason", privacy: .open)",
                        in: .auth
                    )
                    throw error
                }
            }
        )
    }
}
