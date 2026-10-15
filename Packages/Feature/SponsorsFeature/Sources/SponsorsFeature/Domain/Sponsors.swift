/// Every sponsor, grouped by level. A level with no sponsors is absent.
public struct Sponsors: Equatable, Hashable, Sendable {
    /// The sponsors at each level that has any.
    private let levels: [SponsorLevel: [Sponsor]]

    /// Creates the grouping from a flat list of sponsors.
    /// - Parameter sponsors: The sponsors to group. Each level keeps their order.
    public init(_ sponsors: [Sponsor]) {
        // Grouping never yields an empty array, so a level is absent or full.
        levels = Dictionary(grouping: sponsors, by: \.level)
    }

    /// A Boolean value indicating whether no level has a sponsor.
    public var isEmpty: Bool {
        levels.isEmpty
    }

    /// The levels that have at least one sponsor, best first.
    public var rankedLevels: [SponsorLevel] {
        SponsorLevel.allCases.filter { levels.keys.contains($0) }
    }

    /// Returns the sponsors at a level.
    /// - Parameter level: The level to read.
    /// - Returns: The sponsors at that level, or an empty array if none.
    public func sponsors(at level: SponsorLevel) -> [Sponsor] {
        levels[level, default: []]
    }
}
