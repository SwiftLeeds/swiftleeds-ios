import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of the repository call `FetchSchedule` makes.
@Suite struct FetchScheduleTests {
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
