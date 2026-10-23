import Dependencies
import LogKit

extension SignOut {
    /// Records the outcome the user got, then rethrows.
    ///
    /// The store names the mechanism. This names what it meant: either the session is gone, or the
    /// user believes they signed out while it is still on the device.
    public func logging() -> SignOut {
        SignOut {
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do {
                try await self()
                let entry = LoggedSignOutOutcome.success
                log(entry.level, .auth, entry.message)
            } catch {
                let entry = LoggedSignOutOutcome.failure
                log(entry.level, .auth, entry.message)
                throw error
            }
        }
    }
}
