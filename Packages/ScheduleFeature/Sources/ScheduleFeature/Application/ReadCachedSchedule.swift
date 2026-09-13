import Dependencies

/// Returns the current conference's schedule if the device holds a recent one.
public struct ReadCachedSchedule: Sendable {
    private var perform: @Sendable () -> Schedule?

    public init(perform: @escaping @Sendable () -> Schedule?) {
        self.perform = perform
    }

    public func callAsFunction() -> Schedule? {
        perform()
    }
}

extension ReadCachedSchedule: DependencyKey {
    public static var liveValue: ReadCachedSchedule {
        ReadCachedSchedule {
            @Dependency(\.localScheduleStore) var local
            @Dependency(\.date) var date

            guard let stored = local.load(.current), stored.isFresh(at: date.now) else {
                return nil
            }
            return stored.schedule
        }
    }

    public static let testValue = ReadCachedSchedule {
        reportIssue("ReadCachedSchedule is unimplemented")
        return nil
    }
}

extension DependencyValues {
    public var readCachedSchedule: ReadCachedSchedule {
        get { self[ReadCachedSchedule.self] }
        set { self[ReadCachedSchedule.self] = newValue }
    }
}
