import Foundation
import SponsorsFeature

extension SponsorListDTO.SponsorDTO {
    static func fixture(
        id: String = "sponsor-1",
        name: String = "CodeMagic",
        subtitle: String = "CI/CD for mobile dev teams",
        image: String = "https://example.invalid/logo.png",
        sponsorLevel: String = "platinum",
        url: String = "https://example.invalid",
        jobs: [SponsorListDTO.JobDTO] = []
    ) -> Self {
        SponsorListDTO.SponsorDTO(
            id: id,
            name: name,
            subtitle: subtitle,
            image: image,
            sponsorLevel: sponsorLevel,
            url: url,
            jobs: jobs
        )
    }
}

extension SponsorListDTO.JobDTO {
    static func fixture(
        id: UUID = UUID(),
        title: String = "Senior iOS Engineer",
        details: String = "Bringing all your Swift skills to the fore",
        location: String = "Leeds",
        url: String = "https://example.invalid/job"
    ) -> Self {
        SponsorListDTO.JobDTO(id: id, title: title, details: details, location: location, url: url)
    }
}
