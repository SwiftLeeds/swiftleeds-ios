import Dependencies
import Foundation

/// Turns the backend's sponsor list into this context's values.
package struct SponsorMapper: Sendable {
    /// The backend named a level we do not sell.
    package struct LevelError: Error, Equatable {
        package let sponsor: String
        package let level: String
    }

    package var map: @Sendable (SponsorListDTO) throws(LevelError) -> Sponsors

    package init(map: @escaping @Sendable (SponsorListDTO) throws(LevelError) -> Sponsors) {
        self.map = map
    }
}

extension SponsorMapper {
    package static let live = SponsorMapper { list throws(LevelError) in
        var sponsors: [Sponsor] = []
        for dto in list.data {
            guard let level = SponsorLevel(rawValue: dto.sponsorLevel) else {
                throw LevelError(sponsor: dto.name, level: dto.sponsorLevel)
            }
            sponsors.append(
                Sponsor(
                    id: SponsorID(dto.id),
                    name: dto.name,
                    subtitle: dto.subtitle,
                    level: level,
                    logoURL: link(dto.image),
                    websiteURL: link(dto.url),
                    jobs: dto.jobs.map(job)
                )
            )
        }
        return Sponsors(sponsors)
    }

    private static func job(_ dto: SponsorListDTO.JobDTO) -> Job {
        Job(
            id: JobID(dto.id),
            title: dto.title,
            details: dto.details,
            location: dto.location,
            url: link(dto.url)
        )
    }

    // The backend sends an empty string for "no link", which parses to nil.
    private static func link(_ value: String) -> URL? {
        URL(string: value)
    }
}

private enum SponsorMapperKey: DependencyKey {
    static var liveValue: SponsorMapper { .live }
    static var testValue: SponsorMapper { liveValue }
}

extension DependencyValues {
    package var sponsorMapper: SponsorMapper {
        get { self[SponsorMapperKey.self] }
        set { self[SponsorMapperKey.self] = newValue }
    }
}
