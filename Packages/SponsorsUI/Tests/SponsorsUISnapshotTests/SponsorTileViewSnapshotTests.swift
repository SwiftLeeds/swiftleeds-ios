#if os(iOS)
import Foundation
import SnapshotTesting
import SponsorsFeature
import SponsorsUI
import Testing

@MainActor
@Suite struct SponsorTileViewSnapshotTests {
    @Test func platinumWithJobs() {
        let view = SponsorTileView(sponsor: .platinumWithJobs)

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func goldWithoutJobs() {
        let view = SponsorTileView(sponsor: .goldWithoutJobs)

        assertTileSnapshots(of: view, width: gridTileWidth)
    }
}

extension Sponsor {
    fileprivate static let platinumWithJobs = Sponsor(
        id: SponsorID("platinum-sponsor"),
        name: "Sky",
        subtitle: "Believe in better",
        level: .platinum,
        logoURL: nil,
        websiteURL: nil,
        jobs: [.seniorEngineer]
    )

    fileprivate static let goldWithoutJobs = Sponsor(
        id: SponsorID("gold-sponsor"),
        name: "Deliveroo",
        subtitle: "Food delivery, at speed",
        level: .gold,
        logoURL: nil,
        websiteURL: nil,
        jobs: []
    )
}

extension Job {
    fileprivate static let seniorEngineer = Job(
        id: JobID(UUID()),
        title: "Senior iOS Engineer",
        details: "Bringing all your Swift skills to the fore",
        location: "Leeds",
        url: nil
    )
}
#endif
