import Foundation

package struct SponsorListDTO: Decodable {
    /// The server named a level we do not sell. Carried as data, so adding a
    /// level needs no case here.
    package struct LevelError: Error, Equatable {
        package let sponsor: String
        package let level: String
    }

    let data: [SponsorDTO]

    struct SponsorDTO: Decodable {
        let id: String
        let name: String
        let subtitle: String
        let image: String
        let sponsorLevel: String
        let url: String
        let jobs: [JobDTO]
    }

    struct JobDTO: Decodable {
        let id: UUID
        let title: String
        let details: String
        let location: String
        let url: String
    }
}

extension SponsorListDTO {
    package func sponsors() throws(LevelError) -> [Sponsor] {
        var sponsors: [Sponsor] = []
        for dto in data {
            guard let level = SponsorLevel(rawValue: dto.sponsorLevel) else {
                throw LevelError(sponsor: dto.name, level: dto.sponsorLevel)
            }
            sponsors.append(
                Sponsor(
                    id: SponsorID(dto.id),
                    name: dto.name,
                    subtitle: dto.subtitle,
                    level: level,
                    logoURL: Self.link(dto.image),
                    websiteURL: Self.link(dto.url),
                    jobs: dto.jobs.map(Self.job)
                )
            )
        }
        return sponsors
    }

    private static func job(_ dto: JobDTO) -> Job {
        Job(
            id: JobID(dto.id),
            title: dto.title,
            details: dto.details,
            location: dto.location,
            url: link(dto.url)
        )
    }

    /// A link the server could not express is absent, not a failure. These are
    /// decorative, and the server sends an empty string for "no link".
    private static func link(_ value: String) -> URL? {
        value.isEmpty ? nil : URL(string: value)
    }
}
