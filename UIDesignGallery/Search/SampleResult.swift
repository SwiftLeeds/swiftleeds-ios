import Foundation

/// One thing search can find, whatever part of the conference it came from.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives. The results are built from the schedule's and the
/// sponsors' own samples, so search finds exactly what those screens show.
struct SampleResult: Identifiable, Equatable, Hashable, Sendable {
    /// What part of the conference a result came from.
    enum Kind: String, CaseIterable, Identifiable, Equatable, Hashable, Sendable {
        /// A session on the schedule.
        case talk

        /// Someone at the conference.
        case person

        /// A company paying for the conference.
        case sponsor

        /// Tells one kind from another.
        var id: String { rawValue }

        /// What a heading calls a group of these.
        var heading: String {
            switch self {
            case .talk: "Talks"
            case .person: "People"
            case .sponsor: "Sponsors"
            }
        }

        /// The SF Symbol that stands for this kind beside a result.
        var symbol: String {
            switch self {
            case .talk: "text.bubble"
            case .person: "person"
            case .sponsor: "building.2"
            }
        }
    }

    /// Tells one sample result from another.
    let id: String

    /// What part of the conference it came from.
    let kind: Kind

    /// What the row calls it.
    let title: String

    /// What the row says under the title.
    let detail: String

    /// The session this result opens, or `nil` when its screen is still to come.
    let session: SampleSession?

    /// The person this result opens, or `nil` for a result that is not a
    /// person.
    let person: SamplePerson?

    /// Returns whether this result answers what a person typed.
    ///
    /// The detail counts as well as the title, so a company name finds the
    /// people who work there and not only the company.
    ///
    /// - Parameter query: What the person typed.
    func matches(_ query: String) -> Bool {
        title.localizedCaseInsensitiveContains(query)
            || detail.localizedCaseInsensitiveContains(query)
    }
}

extension SampleResult {
    /// Everything search can find.
    static let all: [SampleResult] = talks + people + sponsors

    /// Every session on the schedule, as a result.
    static let talks: [SampleResult] = SampleSession.dayOne.map { session in
        SampleResult(
            id: "talk-\(session.id)",
            kind: .talk,
            title: session.title,
            detail: "\(session.time) • \(session.room)",
            session: session,
            person: nil,
        )
    }

    /// Everyone at the conference, as a result.
    ///
    /// The detail names the person's standings, then what they do.
    static let people: [SampleResult] = SamplePerson.all.map { person in
        let roles = person.roles.all.map(\.name).joined(separator: " • ")
        return SampleResult(
            id: "person-\(person.id)",
            kind: .person,
            title: person.name,
            detail: "\(roles) • \(person.detail)",
            session: nil,
            person: person,
        )
    }

    /// Every company paying for the conference, as a result.
    ///
    /// A result carries the tier rather than the company's own line, because
    /// the sponsors screen puts the tier in a heading and a search result has
    /// no heading to carry it.
    static let sponsors: [SampleResult] =
        tier("Headline sponsor", SampleSponsor.headline)
        + tier("Gold sponsor", SampleSponsor.gold)

    /// Returns one tier's companies as results.
    ///
    /// - Parameters:
    ///   - name: What the conference calls this tier, as a result prints it.
    ///   - sponsors: The companies at this tier.
    private static func tier(_ name: String, _ sponsors: [SampleSponsor]) -> [SampleResult] {
        sponsors.map { sponsor in
            SampleResult(
                id: "sponsor-\(sponsor.id)",
                kind: .sponsor,
                title: sponsor.name,
                detail: name,
                session: nil,
                person: nil,
            )
        }
    }
}
