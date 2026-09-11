import Dependencies
import Foundation

/// Turns the backend's sponsor list into sponsors.
package struct SponsorMapper: Sendable {
    /// A value the backend sent could not become part of the model.
    package struct MappingError: Error, Equatable {
        package let sponsor: String
        package let field: SponsorListDTO.SponsorDTO.CodingKeys
        package let value: String
    }

    package var map: @Sendable (SponsorListDTO) throws(MappingError) -> Sponsors

    package init(map: @escaping @Sendable (SponsorListDTO) throws(MappingError) -> Sponsors) {
        self.map = map
    }
}

extension SponsorMapper {
    package static let live = SponsorMapper { list throws(MappingError) in
        var sponsors: [Sponsor] = []
        for dto in list.data {
            guard let level = SponsorLevel(rawValue: dto.sponsorLevel) else {
                throw MappingError(
                    sponsor: dto.name,
                    field: .sponsorLevel,
                    value: dto.sponsorLevel
                )
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

    private static func link(_ value: String) -> URL? {
        URL(string: value)
    }
}

private enum SponsorMapperKey: DependencyKey {
    static var liveValue: SponsorMapper { .live.logging() }
    static var testValue: SponsorMapper { liveValue }
}

extension DependencyValues {
    package var sponsorMapper: SponsorMapper {
        get { self[SponsorMapperKey.self] }
        set { self[SponsorMapperKey.self] = newValue }
    }
}
