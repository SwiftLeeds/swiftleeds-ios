import Dependencies
import LogKit

extension LoginMapper {
    /// Wraps the mapper rather than the gateway, which has already narrowed the failure to
    /// `AuthenticationError` and lost the reason.
    func loggingFailures() -> LoginMapper {
        LoginMapper { data, response throws(LoginResponseFailure) in
            do throws(LoginResponseFailure) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedLoginFailure(error)
                log(entry.level, .auth, entry.message)
                throw error
            }
        }
    }
}
