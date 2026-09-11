/// Every sponsor, grouped by level. A level with no sponsors is absent.
public struct Sponsors: Equatable, Hashable, Sendable {
    private let levels: [SponsorLevel: [Sponsor]]

    public init(_ sponsors: [Sponsor]) {
        // Grouping never yields an empty array, so a level is absent or full.
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
