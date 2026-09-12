#if os(iOS)
import Foundation
import SnapshotTesting
import SponsorsFeature
import SponsorsUI
import Testing

@MainActor
@Suite struct SponsorsContentViewSnapshotTests {
    @Test func loading() {
        let view = SponsorsContentView(state: .loading)

        assertScreenSnapshots(of: view)
    }

    @Test func empty() {
        let view = SponsorsContentView(state: .empty)

        assertScreenSnapshots(of: view)
    }

    @Test func everyLevel() {
        let view = SponsorsContentView(state: .loaded(.everyLevel))

        assertScreenSnapshots(of: view)
    }
}

private extension Sponsors {
    static let everyLevel = Sponsors([
        .sponsor(named: "Sky", at: .platinum, jobs: [.seniorEngineer]),
        .sponsor(named: "Deliveroo", at: .gold),
        .sponsor(named: "Monzo", at: .gold),
        .sponsor(named: "Bloomberg", at: .silver),
        .sponsor(named: "Trainline", at: .silver),
    ])
}

private extension Sponsor {
    static func sponsor(
        named name: String,
        at level: SponsorLevel,
        jobs: [Job] = []
    ) -> Sponsor {
        Sponsor(
            id: SponsorID(name.lowercased()),
            name: name,
            subtitle: "Believe in better",
            level: level,
            logoURL: nil,
            websiteURL: nil,
            jobs: jobs
        )
    }
}

private extension Job {
    static let seniorEngineer = Job(
        id: JobID(UUID()),
        title: "Senior iOS Engineer",
        details: "Bringing all your Swift skills to the fore",
        location: "Leeds",
        url: nil
    )
}
#endif
