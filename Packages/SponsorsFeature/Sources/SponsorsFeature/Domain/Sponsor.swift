import Foundation

/// A company sponsoring the conference.
public struct Sponsor: Equatable, Hashable, Identifiable, Sendable {
    public let id: SponsorID
    public let name: String
    public let subtitle: String
    public let level: SponsorLevel

    /// Absent when the sponsor has no logo.
    public let logoURL: URL?

    /// Absent when the sponsor supplied no link.
    public let websiteURL: URL?

    public let jobs: [Job]

    public init(
        id: SponsorID,
        name: String,
        subtitle: String,
        level: SponsorLevel,
        logoURL: URL?,
        websiteURL: URL?,
        jobs: [Job]
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.level = level
        self.logoURL = logoURL
        self.websiteURL = websiteURL
        self.jobs = jobs
    }
}
