import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

@Suite struct FetchScheduleTests {
    /// Records each event a `ScheduleRepository` is asked for.
    fileprivate actor EventRecorder {
        /// The events asked for, in order, with `nil` standing for the current schedule.
        private(set) var events: [UUID?] = []

        /// Records an event the repository was asked for.
        ///
        /// - Parameter event: The event asked for, or `nil` for the current schedule.
        func record(_ event: UUID?) {
            events.append(event)
        }
    }

    @Test func whenFetchingTheCurrentSchedule_shouldAskTheRepositoryForNoEvent() async throws {
        let recorder = EventRecorder()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: recorder, answering: try .fixture())
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(await recorder.events == [nil])
    }

    @Test func whenFetchingOneEvent_shouldAskTheRepositoryForThatEvent() async throws {
        let recorder = EventRecorder()
        let event = UUID()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: recorder, answering: try .fixture())
        } operation: {
            try await FetchSchedule.liveValue(for: event)
        }

        #expect(await recorder.events == [event])
    }
}

extension ScheduleRepository {
    fileprivate static func recording(
        into recorder: FetchScheduleTests.EventRecorder,
        answering answer: Schedule,
    ) -> ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async -> Schedule in
                await recorder.record(nil)
                return answer
            },
            fetchSchedule: { event async -> Schedule in
                await recorder.record(event)
                return answer
            },
        )
    }
}
