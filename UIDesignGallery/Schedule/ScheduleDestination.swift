/// A screen the schedule pushes on top of itself.
enum ScheduleDestination: Equatable, Hashable {
    /// What one session is about, and what a person can do about it.
    case session(SampleSession)

    /// The signed-in person's own standing at the conference.
    case profile
}
