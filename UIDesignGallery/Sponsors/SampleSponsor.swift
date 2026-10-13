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

    /// What the company wants to say, or `nil` when it says nothing.
    ///
    /// The tier is not a field here. A section heading already names it, so
    /// repeating it on every row would say the same thing twice.
    let detail: String?
}

extension SampleSponsor {
    /// The one company at the top tier.
    static let headline: [SampleSponsor] = [
        SampleSponsor(name: "Northern Software", detail: "3 open roles")
    ]

    /// The companies at the tier below, one with an offer and one without.
    static let gold: [SampleSponsor] = [
        SampleSponsor(name: "Pennine Labs", detail: "1 open role"),
        SampleSponsor(name: "Aire Systems", detail: nil),
    ]
}
