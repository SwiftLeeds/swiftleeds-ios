import Dependencies
import Foundation
import ScheduleFeature
import Testing

@Suite struct FetchScheduleTests {
    @Test func whenFetchingTheCurrentSchedule_shouldAskTheRepositoryForNoEvent() async throws {
        let spy = EventSpy()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy)
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(await spy.events == [nil])
    }

    @Test func whenFetchingOneEvent_shouldAskTheRepositoryForThatEvent() async throws {
        let spy = EventSpy()
        let event = UUID()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy)
        } operation: {
            try await FetchSchedule.liveValue(for: event)
        }

        #expect(await spy.events == [event])
    }
}

private actor EventSpy {
    private(set) var events: [UUID?] = []

    func record(_ event: UUID?) {
        events.append(event)
    }
}

private extension ScheduleRepository {
    static func recording(into spy: EventSpy) -> ScheduleRepository {
        ScheduleRepository { event async throws(ScheduleFetchError) -> Schedule in
            await spy.record(event)
            return Schedule(
                data: Schedule.Data(
                    event: Schedule.Event(
                        id: UUID(),
                        name: "SwiftLeeds 2026",
                        location: "The Playhouse, Leeds",
                        date: Date(timeIntervalSince1970: 0)
                    ),
                    events: [],
                    days: []
                )
            )
        }
    }
}
