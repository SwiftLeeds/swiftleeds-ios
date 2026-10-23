import Foundation

package struct StoredSchedule: Codable, Sendable {
    /// The length of one hour in seconds.
    private static let secondsPerHour: TimeInterval = 3_600

    /// The number of hours in one day.
    private static let hoursPerDay: TimeInterval = 24

    /// The seconds a stored schedule stays fresh.
    ///
    /// The backend sends no cache headers, so the app picks the number.
    private static let lifetime: TimeInterval = secondsPerHour * hoursPerDay

    package let schedule: Schedule
    package let storedAt: Date

    package init(schedule: Schedule, storedAt: Date) {
        self.schedule = schedule
        self.storedAt = storedAt
    }

    package func isFresh(at now: Date) -> Bool {
        now.timeIntervalSince(storedAt) < Self.lifetime
    }
}
