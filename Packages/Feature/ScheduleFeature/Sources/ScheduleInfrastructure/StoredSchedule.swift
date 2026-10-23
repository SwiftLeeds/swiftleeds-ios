import Foundation
import ScheduleDomain

package struct StoredSchedule: Codable, Sendable {
    /// How long a stored schedule stays fresh: one day, in seconds.
    ///
    /// The backend sends no cache headers, so this value is the only limit.
    private static let lifetime: TimeInterval = 86_400

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
