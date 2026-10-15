/// A screen the schedule opens over itself as the gallery starts.
///
/// A session is pushed, and Settings and Sign in are presented, so this says
/// which screen to open rather than how it arrives.
enum ScheduleDestination: Equatable, Hashable {
    /// What one session is about, and what a person can do about it.
    case session(SampleSession)

    /// Who a person is, what they speak about and where to find them.
    case person(SamplePerson)

    /// What a person can change about the app.
    case settings

    /// The signed-in person's own standing at the conference, which sits one
    /// step inside Settings.
    case profile

    /// One part of Settings, which sits one step inside it.
    case settingsCategory(SettingsCategory)

    /// The screen that signs a person in with their ticket.
    case signIn(SignInState)

    /// A ticket, shown full size.
    case ticket(SampleTicket)
}
