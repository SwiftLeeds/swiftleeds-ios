import Dependencies
import LogKit

extension SignIn {
    /// Records the outcome the user got, then rethrows.
    ///
    /// The cause already reached the log at the seam that knew it: the transport, the mapper, or
    /// the session store. This line says what that cost the person signing in.
    public func logging() -> SignIn {
        SignIn { credential in
            do {
                try await self(credential)
            } catch let error as SignInError {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedSignInOutcome(error)
                log(entry.level, .auth, entry.message)
                throw error
            } catch {
                // The gateway throws only SignInError, so in the live app this is the session
                // store. The message names no step: `narrowingFailures()` has no catch-all, so a
                // third error type would reach here without the store ever running.
                @Dependency(\.log) var log
                log.error("Signing in did not finish, and no sign-in outcome explains it", in: .auth)
                throw error
            }
        }
    }
}
