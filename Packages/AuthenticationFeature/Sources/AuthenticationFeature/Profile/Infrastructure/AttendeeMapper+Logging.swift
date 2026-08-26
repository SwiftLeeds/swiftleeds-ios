import Dependencies
import Foundation
import LogKit

extension AttendeeMapper {
    /// Records whether the response parsed, then returns or rethrows.
    ///
    /// The public ``AttendeeFetchError`` is deliberately bare, so this is the only place a
    /// rejection's reason survives.
    package func logging() -> AttendeeMapper {
        AttendeeMapper { data, response throws(ResponseError) in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do throws(ResponseError) {
                let attendee = try map(data, response)
                let entry = LoggedAttendeeResponseOutcome.success
                log(entry.level, .profile, entry.message)
                return attendee
            } catch {
                let entry = LoggedAttendeeResponseOutcome.failure(error)
                log(entry.level, .profile, entry.message)
                throw error
            }
        }
    }
}
