import Dependencies
import LogKit

extension SignOut {
    /// Records that signing out did not finish, then rethrows.
    ///
    /// The store names the mechanism that refused. This names what it cost the user: they believe
    /// they signed out, and the session is still on the device.
    public func logging() -> SignOut {
        SignOut {
            do {
                try await self()
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                log.error("Signing out did not finish, so the session is still on this device", in: .auth)
                throw error
            }
        }
    }
}
