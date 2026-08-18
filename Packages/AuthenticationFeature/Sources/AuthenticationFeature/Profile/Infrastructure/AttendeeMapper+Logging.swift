import Dependencies
import Foundation
import LogKit

extension AttendeeMapper {
    /// Wraps the mapper rather than the repository, which has already narrowed the failure to
    /// `AttendeeFetchError` and lost the reason.
    func loggingFailures() -> AttendeeMapper {
        AttendeeMapper { data, response throws(ResponseError) in
            do throws(ResponseError) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                log.error("The attendee response was rejected: \(error, name: "reason", privacy: .open)", in: .profile)
                throw error
            }
        }
    }
}
