import AuthenticationDomain
import Dependencies
import LogKit

extension SignIn {
    /// Records the outcome the user got, then rethrows.
    public func logging() -> SignIn {
        SignIn { credential in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do {
                try await self(credential)
                let entry = LoggedSignInOutcome.success
                log(entry.level, .auth, entry.message)
            } catch let error as SignInError {
                let entry = LoggedSignInOutcome.failure(error)
                log(entry.level, .auth, entry.message)
                throw error
            } catch {
                let entry = LoggedSignInOutcome.unexplainedFailure
                log(entry.level, .auth, entry.message)
                throw error
            }
        }
    }
}
