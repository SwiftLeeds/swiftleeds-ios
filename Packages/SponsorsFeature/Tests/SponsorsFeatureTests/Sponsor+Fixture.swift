import Foundation
import SponsorsFeature

extension Sponsor {
    static func fixture(
        id: SponsorID = SponsorID("sponsor-1"),
        name: String = "CodeMagic",
        subtitle: String = "CI/CD for mobile dev teams",
        level: SponsorLevel = .platinum,
        logoURL: URL? = URL(string: "https://example.invalid/logo.png"),
        websiteURL: URL? = URL(string: "https://example.invalid"),
        jobs: [Job] = []
    ) -> Sponsor {
        Sponsor(
            id: id,
            name: name,
            subtitle: subtitle,
            level: level,
            logoURL: logoURL,
            websiteURL: websiteURL,
            jobs: jobs
        )
    }
}
