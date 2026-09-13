import Dependencies

/// The schedules this device already holds.
public struct LocalScheduleStore: Sendable {
    package var load: @Sendable (ScheduleRequest) -> StoredSchedule?
    package var save: @Sendable (StoredSchedule, ScheduleRequest) -> Void

    package init(
        load: @escaping @Sendable (ScheduleRequest) -> StoredSchedule?,
        save: @escaping @Sendable (StoredSchedule, ScheduleRequest) -> Void
    ) {
        self.load = load
        self.save = save
    }

    /// A store that keeps nothing. A caller that wants a schedule to survive a launch asks for one.
    package static let notPersisted = LocalScheduleStore(load: { _ in nil }, save: { _, _ in })
}

extension LocalScheduleStore: DependencyKey {
    public static let liveValue = LocalScheduleStore.notPersisted
    public static let testValue = LocalScheduleStore.notPersisted
}

extension DependencyValues {
    public var localScheduleStore: LocalScheduleStore {
        get { self[LocalScheduleStore.self] }
        set { self[LocalScheduleStore.self] = newValue }
    }
}
