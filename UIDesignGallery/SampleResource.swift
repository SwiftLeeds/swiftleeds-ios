import Foundation

/// A page or a screen a row points a person at.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
struct SampleResource: Identifiable, Equatable, Hashable, Sendable {
    /// Where a resource opens.
    enum Destination: Equatable, Hashable, Sendable {
        /// A screen inside the app.
        case screen

        /// A page on the web, which leaves the app.
        case page
    }

    /// Tells one sample resource from another.
    let id: String

    /// What the row calls it.
    let title: String

    /// What it holds, or `nil` when the title says enough.
    let detail: String?

    /// The SF Symbol that stands for it.
    let symbol: String

    /// Where it opens.
    let destination: Destination
}

extension SampleResource {
    /// The venue's address, which opens in Maps.
    static let address = SampleResource(
        id: "address",
        title: "Playhouse Square, Quarry Hill",
        detail: "Leeds LS2 7UP",
        symbol: "mappin.and.ellipse",
        destination: .page
    )

    /// What a person needs to read before they arrive.
    ///
    /// The FAQ is the one entry on the web, so the list shows both marks.
    static let practical: [SampleResource] = [
        SampleResource(
            id: "conduct",
            title: "Code of conduct",
            detail: "What we expect of everyone here",
            symbol: "hand.raised",
            destination: .screen
        ),
        SampleResource(
            id: "accommodation",
            title: "Accommodation",
            detail: "Places to stay near the venue",
            symbol: "bed.double",
            destination: .screen
        ),
        SampleResource(
            id: "joining",
            title: "Joining instructions",
            detail: "When to arrive, and what to bring",
            symbol: "doc.text",
            destination: .screen
        ),
        SampleResource(
            id: "faq",
            title: "FAQ",
            detail: "Answers to what we get asked most",
            symbol: "questionmark.circle",
            destination: .page
        ),
    ]

    /// What the conference asks of people, and what it promises them.
    ///
    /// The code of conduct is a screen, so `List` marks it. The privacy
    /// policy is on the web, so the row draws its own arrow.
    static let policies: [SampleResource] = [
        SampleResource(
            id: "conduct",
            title: "Code of conduct",
            detail: "What we expect of everyone here",
            symbol: "hand.raised",
            destination: .screen
        ),
        SampleResource(
            id: "privacy",
            title: "Privacy policy",
            detail: "What we keep about you, and why",
            symbol: "lock",
            destination: .page
        ),
    ]

    /// The places the conference publishes, all of them on the web.
    static let outreach: [SampleResource] = [
        SampleResource(
            id: "website",
            title: "Website",
            detail: nil,
            symbol: "safari",
            destination: .page
        ),
        SampleResource(
            id: "podcast",
            title: "Podcast",
            detail: nil,
            symbol: "mic",
            destination: .page
        ),
        SampleResource(
            id: "youtube",
            title: "YouTube",
            detail: nil,
            symbol: "play.rectangle",
            destination: .page
        ),
    ]

    /// The ways to reach the people who run the conference.
    ///
    /// Each one leaves the app: writing opens Mail, and the rest open their
    /// own apps or the web.
    static let contact: [SampleResource] = [
        SampleResource(
            id: "email",
            title: "Email the organizers",
            detail: "hello@swiftleeds.co.uk",
            symbol: "envelope",
            destination: .page
        ),
        SampleResource(
            id: "x",
            title: "Message us on X",
            detail: "@swift_leeds",
            symbol: "at",
            destination: .page
        ),
    ]

    /// The conference's own screen, and the places it publishes.
    static let swiftLeeds: [SampleResource] =
        [
            SampleResource(
                id: "about",
                title: "About SwiftLeeds",
                detail: "Who runs the conference",
                symbol: "info.circle",
                destination: .screen
            )
        ] + outreach
}
