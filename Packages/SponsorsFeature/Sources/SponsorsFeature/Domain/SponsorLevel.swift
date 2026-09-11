/// What a sponsor bought, which decides where they appear.
///
/// The cases are declared in rank order, so `allCases` ranks them and nothing
/// else has to.
public enum SponsorLevel: String, CaseIterable, Equatable, Hashable, Sendable {
    case platinum
    case gold
    case silver
}
