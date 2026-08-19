import Dependencies
import Foundation
import LogKit

extension AttendeeMapper {
    package func loggingFailures() -> AttendeeMapper {
        AttendeeMapper { data, response throws(ResponseError) in
            do throws(ResponseError) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedAttendeeFetchError(error)
                log(entry.level, .profile, entry.message)
                throw error
            }
        }
    }
}
