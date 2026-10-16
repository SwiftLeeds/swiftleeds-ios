import Dependencies

/// Returns the schedule of the conference that is currently running.
public struct FetchCurrentSchedule: Sendable {
    private var perform: @Sendable () async throws(ScheduleFetchError) -> Schedule

    public init(perform: @escaping @Sendable () async throws(ScheduleFetchError) -> Schedule) {
        self.perform = perform
    }

    public func callAsFunction() async throws(ScheduleFetchError) -> Schedule {
        try await perform()
    }
}

extension FetchCurrentSchedule: DependencyKey {
    public static var liveValue: FetchCurrentSchedule {
        FetchCurrentSchedule { () async throws(ScheduleFetchError) -> Schedule in
            @Dependency(\.scheduleRepository) var scheduleRepository
            return try await scheduleRepository.fetchCurrentSchedule()
        }
    }

    public static let testValue = FetchCurrentSchedule(
        perform: { () async throws(ScheduleFetchError) -> Schedule in
            reportIssue("FetchCurrentSchedule is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchCurrentSchedule: FetchCurrentSchedule {
        get { self[FetchCurrentSchedule.self] }
        set { self[FetchCurrentSchedule.self] = newValue }
    }
}
