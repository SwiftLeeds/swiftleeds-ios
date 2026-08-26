import Dependencies
import LogKit

extension LoginMapper {
    /// Records whether the response parsed, then returns or rethrows.
    ///
    /// The public ``SignInError`` is deliberately bare, so this is the only place a rejection's
    /// reason survives.
    package func logging() -> LoginMapper {
        LoginMapper { data, response throws(ResponseError) in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do throws(ResponseError) {
                let token = try map(data, response)
                let entry = LoggedLoginResponseOutcome.success
                log(entry.level, .auth, entry.message)
                return token
            } catch {
                let entry = LoggedLoginResponseOutcome.failure(error)
                log(entry.level, .auth, entry.message)
                throw error
            }
        }
    }
}
