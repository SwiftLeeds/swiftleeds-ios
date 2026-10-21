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

    /// What the company wants to say, or `nil` when it says nothing.
    let tagline: String?

    /// The placeholder that stands in for the company's logo.
    let logo: SampleLogo

    /// The company's own website.
    let website: SampleLink

    /// The jobs the company is hiring for, which is empty when it has none.
    let jobs: [SampleJob]

    /// What the sponsor's tier makes the company, as a line of text prints it.
    var standing: String {
        "\(tier.title) sponsor"
    }

    /// How many jobs the company is hiring for, or `nil` when it has none.
    var openRoles: String? {
        switch jobs.count {
        case 0: nil
        case 1: "1 open role"
        case let count: "\(count) open roles"
        }
    }
}

extension SampleSponsor {
    /// Every company paying for the conference, from the highest tier down.
    static let all: [SampleSponsor] = [
        SampleSponsor(
            name: "Northern Software",
            tier: .platinum,
            tagline: "Software for the north, built in the north",
            logo: SampleLogo(symbol: "network"),
            website: .website("northern.example.com"),
            jobs: [
                job("Senior iOS Engineer", in: "Leeds"),
                job("Mobile Platform Engineer", in: "Manchester"),
                job("Design Systems Designer", in: "Remote"),
            ],
        ),
        SampleSponsor(
            name: "Calder Digital",
            tier: .platinum,
            tagline: nil,
            logo: SampleLogo(symbol: "waveform"),
            website: .website("calder.example.com"),
            jobs: [],
        ),
        SampleSponsor(
            name: "Pennine Labs",
            tier: .gold,
            tagline: "Tools that make developers faster",
            logo: SampleLogo(symbol: "flask"),
            website: .website("pennine.example.com"),
            jobs: [job("Developer Advocate", in: "Leeds")],
        ),
        SampleSponsor(
            name: "Aire Systems",
            tier: .gold,
            tagline: nil,
            logo: SampleLogo(symbol: "drop"),
            website: .website("aire.example.com"),
            jobs: [],
        ),
        SampleSponsor(
            name: "Dales Mobile",
            tier: .gold,
            tagline: "Apps for people who work outdoors",
            logo: SampleLogo(symbol: "mountain.2"),
            website: .website("dales.example.com"),
            jobs: [
                job("iOS Engineer", in: "York"),
                job("QA Engineer", in: "Remote"),
            ],
        ),
        SampleSponsor(
            name: "Ouse Apps",
            tier: .silver,
            tagline: nil,
            logo: SampleLogo(symbol: "square.stack.3d.up"),
            website: .website("ouse.example.com"),
            jobs: [],
        ),
        SampleSponsor(
            name: "Roundhay Mobile Engineering Collective",
            tier: .silver,
            tagline: "A co-operative of mobile engineers",
            logo: SampleLogo(symbol: "leaf"),
            website: .website("roundhay.example.com"),
            jobs: [job("Swift Engineer", in: "Leeds")],
        ),
        SampleSponsor(
            name: "Skipton Soft",
            tier: .silver,
            tagline: nil,
            logo: SampleLogo(symbol: "hammer"),
            website: .website("skipton.example.com"),
            jobs: [],
        ),
        SampleSponsor(
            name: "Tyke Tools",
            tier: .silver,
            tagline: nil,
            logo: SampleLogo(symbol: "wrench.and.screwdriver"),
            website: .website("tyke.example.com"),
            jobs: [],
        ),
    ]

    /// Returns the companies at one tier, in the order the conference lists them.
    ///
    /// - Parameter tier: The tier to list.
    /// - Returns: The companies at `tier`.
    static func sponsors(in tier: SampleSponsorTier) -> [SampleSponsor] {
        all.filter { $0.tier == tier }
    }

    /// Returns a job a sample sponsor advertises.
    ///
    /// - Parameters:
    ///   - title: What the job is called.
    ///   - location: The place the job is based.
    /// - Returns: A job whose page is on the example domain.
    private static func job(_ title: String, in location: String) -> SampleJob {
        let page = title.lowercased().replacingOccurrences(of: " ", with: "-")
        return SampleJob(
            title: title,
            location: location,
            link: .website("example.com/jobs/\(page)"),
        )
    }
}
