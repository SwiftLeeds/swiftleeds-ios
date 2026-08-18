import Dependencies
import LogKit

extension LoginMapper {
    func loggingFailures() -> LoginMapper {
        LoginMapper { data, response throws(ResponseError) in
            do throws(ResponseError) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedSignInError(error)
                log(entry.level, .auth, entry.message)
                throw error
            }
        }
    }
}
