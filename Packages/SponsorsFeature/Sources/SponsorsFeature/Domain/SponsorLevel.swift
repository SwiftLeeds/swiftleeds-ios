/// What a sponsor bought. The cases are declared in rank order, so `allCases`
/// ranks them.
public enum SponsorLevel: String, CaseIterable, Equatable, Hashable, Sendable {
    case platinum
    case gold
    case silver
}
