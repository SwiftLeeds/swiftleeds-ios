/// What a sponsor bought.
public enum SponsorLevel: String, CaseIterable, Equatable, Hashable, Sendable {
    /// The highest level.
    case platinum = "platinum"

    /// The middle level.
    case gold = "gold"

    /// The lowest level.
    case silver = "silver"
}
