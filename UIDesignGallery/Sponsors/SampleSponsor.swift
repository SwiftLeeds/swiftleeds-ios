import Foundation

/// A sponsor made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
struct SampleSponsor: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample sponsor from another.
    var id: String { name }

    /// What the company is called.
    let name: String

    /// How much the company gives the conference.
    let tier: SampleSponsorTier

    /// How many jobs the company is hiring for, or `nil` when it has none.
    let detail: String?

    /// What the sponsor's tier makes the company, as a line of text prints it.
    var standing: String {
        "\(tier.title) sponsor"
    }
}

extension SampleSponsor {
    /// Every company paying for the conference, from the highest tier down.
    static let all: [SampleSponsor] = [
        SampleSponsor(name: "Northern Software", tier: .platinum, detail: "3 open roles"),
        SampleSponsor(name: "Calder Digital", tier: .platinum, detail: nil),
        SampleSponsor(name: "Pennine Labs", tier: .gold, detail: "1 open role"),
        SampleSponsor(name: "Aire Systems", tier: .gold, detail: nil),
        SampleSponsor(name: "Dales Mobile", tier: .gold, detail: "2 open roles"),
        SampleSponsor(name: "Ouse Apps", tier: .silver, detail: nil),
        SampleSponsor(
            name: "Roundhay Mobile Engineering Collective",
            tier: .silver,
            detail: "1 open role",
        ),
        SampleSponsor(name: "Skipton Soft", tier: .silver, detail: nil),
        SampleSponsor(name: "Tyke Tools", tier: .silver, detail: nil),
    ]

    /// Returns the companies at one tier, in the order the conference lists them.
    ///
    /// - Parameter tier: The tier to list.
    /// - Returns: The companies at `tier`.
    static func sponsors(in tier: SampleSponsorTier) -> [SampleSponsor] {
        all.filter { $0.tier == tier }
    }
}
