/// How much a company gives the conference, which sets where it is listed.
///
/// The cases run from the highest tier to the lowest.
enum SampleSponsorTier: Identifiable, CaseIterable, Equatable, Hashable, Sendable {
    /// The highest tier.
    case platinum

    /// The tier below platinum.
    case gold

    /// The tier below gold.
    case silver

    /// Tells one tier from another.
    var id: Self { self }

    /// What the conference calls this tier, as a heading prints it.
    ///
    /// This is display text, for the reason `SampleSession` gives.
    var title: String {
        switch self {
        case .platinum: "Platinum"
        case .gold: "Gold"
        case .silver: "Silver"
        }
    }
}
