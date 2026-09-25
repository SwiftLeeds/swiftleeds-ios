/// A screen the schedule opens over itself as the gallery starts.
///
/// A session is pushed and the profile is presented, so this says which screen
/// to open rather than how it arrives.
enum ScheduleDestination: Equatable, Hashable {
    /// What one session is about, and what a person can do about it.
    case session(SampleSession)

    /// The signed-in person's own standing at the conference.
    case profile
}
