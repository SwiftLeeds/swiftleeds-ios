import Dependencies
import Foundation
import ScheduleDomain
import ScheduleFeature
import Testing

/// Checks that the live `FetchSchedule` reaches the live `ScheduleRepository`.
@Suite struct FetchScheduleIntegrationTests {
    /// Resolves `FetchSchedule` in a live context and checks it returns the stored schedule.
    @Test func whenResolvedInLiveContext_shouldReturnStoredSchedule() async throws {
        let stored = StoredSchedule(schedule: try .fixture(eventNamed: "SwiftLeeds 2022"), storedAt: now)

        let schedule = try await withDependencies {
            $0.context = .live
            $0.localScheduleStore = LocalScheduleStore(load: { _ in stored }, save: { _, _ in })
            $0.remoteScheduleStore = RemoteScheduleStore { _ async throws(ScheduleFetchError) -> Schedule in
                throw .couldNotReachServer
            }
            $0.date = .constant(now)
        } operation: {
            @Dependency(\.fetchSchedule) var sut
            return try await sut(for: UUID())
        }

        #expect(schedule.data.event.name == "SwiftLeeds 2022")
    }
}

/// The time the test treats as the current time.
private let now = Date(timeIntervalSince1970: 1_000_000)
