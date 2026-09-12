import Dependencies
import Foundation

/// Returns one conference's schedule.
public struct FetchSchedule: Sendable {
    private var perform: @Sendable (UUID) async throws(ScheduleFetchError) -> Schedule

    public init(perform: @escaping @Sendable (UUID) async throws(ScheduleFetchError) -> Schedule) {
        self.perform = perform
    }

    public func callAsFunction(for event: UUID) async throws(ScheduleFetchError) -> Schedule {
        try await perform(event)
    }
}

extension FetchSchedule: DependencyKey {
    public static var liveValue: FetchSchedule {
        FetchSchedule { event async throws(ScheduleFetchError) -> Schedule in
            @Dependency(\.scheduleRepository) var scheduleRepository
            return try await scheduleRepository.fetch(event)
        }
    }

    public static let testValue = FetchSchedule(
        perform: { _ async throws(ScheduleFetchError) -> Schedule in
            reportIssue("FetchSchedule is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchSchedule: FetchSchedule {
        get { self[FetchSchedule.self] }
        set { self[FetchSchedule.self] = newValue }
    }
}
