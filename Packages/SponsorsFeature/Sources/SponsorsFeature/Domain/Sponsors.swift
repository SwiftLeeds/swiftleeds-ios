/// Every sponsor, grouped by what they bought.
///
/// Ranking is the one rule this feature has, so it lives here rather than in a
/// view. A level with no sponsors is absent; the whole collection may be empty,
/// because a conference with no sponsors yet is a real state.
public struct Sponsors: Equatable, Hashable, Sendable {
    private let levels: [SponsorLevel: [Sponsor]]

    public init(_ sponsors: [Sponsor]) {
        // Grouping never yields an empty array, so absent and empty cannot
        // disagree.
        levels = Dictionary(grouping: sponsors, by: \.level)
    }

    public var isEmpty: Bool {
        levels.isEmpty
    }

    /// The levels that have at least one sponsor, best first.
    public var rankedLevels: [SponsorLevel] {
        SponsorLevel.allCases.filter { levels.keys.contains($0) }
    }

    public func sponsors(at level: SponsorLevel) -> [Sponsor] {
        levels[level, default: []]
    }
}
