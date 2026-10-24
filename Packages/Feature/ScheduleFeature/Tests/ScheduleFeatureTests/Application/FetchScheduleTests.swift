import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

@Suite struct FetchScheduleTests {
    /// A spy that records each event the repository is asked for.
    fileprivate actor EventSpy {
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
        let spy = EventSpy()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy, answering: try .fixture())
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(await spy.events == [nil])
    }

    @Test func whenFetchingOneEvent_shouldAskTheRepositoryForThatEvent() async throws {
        let spy = EventSpy()
        let event = UUID()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy, answering: try .fixture())
        } operation: {
            try await FetchSchedule.liveValue(for: event)
        }

        #expect(await spy.events == [event])
    }
}

extension ScheduleRepository {
    fileprivate static func recording(
        into spy: FetchScheduleTests.EventSpy,
        answering answer: Schedule,
    ) -> ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async -> Schedule in
                await spy.record(nil)
                return answer
            },
            fetchSchedule: { event async -> Schedule in
                await spy.record(event)
                return answer
            },
        )
    }
}
