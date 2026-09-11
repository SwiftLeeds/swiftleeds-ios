import Dependencies
import Foundation

/// Turns the backend's sponsor list into this context's values.
package struct SponsorsReader: Sendable {
    /// The backend named a level we do not sell.
    package struct LevelError: Error, Equatable {
        package let sponsor: String
        package let level: String
    }

    package var read: @Sendable (SponsorListDTO) throws(LevelError) -> [Sponsor]

    package init(read: @escaping @Sendable (SponsorListDTO) throws(LevelError) -> [Sponsor]) {
        self.read = read
    }
}

extension SponsorsReader {
    package static let live = SponsorsReader { list throws(LevelError) in
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
        return sponsors
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

private enum SponsorsReaderKey: DependencyKey {
    static var liveValue: SponsorsReader { .live }
    static var testValue: SponsorsReader { liveValue }
}

extension DependencyValues {
    package var sponsorsReader: SponsorsReader {
        get { self[SponsorsReaderKey.self] }
        set { self[SponsorsReaderKey.self] = newValue }
    }
}
