import Dependencies
import Foundation
import ScheduleFeature
import Testing

@Suite struct ReadCachedScheduleTests {
    @Test func whenTheCurrentScheduleIsStored_shouldReturnIt() throws {
        let schedule = withDependencies {
            $0.localScheduleStore = .holding(.fixture(eventNamed: "SwiftLeeds 2026"), at: now)
            $0.date = .constant(now)
        } operation: {
            ReadCachedSchedule.liveValue()
        }

        #expect(try #require(schedule).data.event.name == "SwiftLeeds 2026")
    }

    @Test func whenNothingIsStored_shouldReturnNothing() {
        let schedule = withDependencies {
            $0.localScheduleStore = .notPersisted
            $0.date = .constant(now)
        } operation: {
            ReadCachedSchedule.liveValue()
        }

        #expect(schedule == nil)
    }

    @Test func whenTheStoredScheduleIsStale_shouldReturnNothing() {
        let schedule = withDependencies {
            $0.localScheduleStore = .holding(.fixture(), at: now)
            $0.date = .constant(now.addingTimeInterval(twoDays))
        } operation: {
            ReadCachedSchedule.liveValue()
        }

        #expect(schedule == nil)
    }
}

private let now = Date(timeIntervalSince1970: 1_000_000)
private let twoDays: TimeInterval = 60 * 60 * 24 * 2

private extension LocalScheduleStore {
    static func holding(_ schedule: Schedule, at storedAt: Date) -> LocalScheduleStore {
        let stored = StoredSchedule(schedule: schedule, storedAt: storedAt)
        return LocalScheduleStore(load: { _ in stored }, save: { _, _ in })
    }
}
