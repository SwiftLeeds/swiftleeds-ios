import Dependencies
import LogKit

extension AuthGateway {
    /// Records whether the server accepted the credentials, then returns or rethrows.
    ///
    /// A response the mapper parsed still has to reach a stored session. This line marks that
    /// boundary, so a failure between the two is not an unexplained gap.
    package func logging() -> AuthGateway {
        AuthGateway { credential in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do {
                let token = try await authenticate(credential)
                let entry = LoggedLoginRequestOutcome.success
                log(entry.level, .auth, entry.message)
                return token
            } catch let error as LoginRequestError {
                if let entry = LoggedLoginRequestOutcome.failure(error) {
                    log(entry.level, .auth, entry.message)
                }
                throw error
            }
        }
    }
}
