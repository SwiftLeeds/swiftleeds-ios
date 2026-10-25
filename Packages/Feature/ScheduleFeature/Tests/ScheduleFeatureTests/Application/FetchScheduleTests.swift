import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

@Suite struct FetchScheduleTests {
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
