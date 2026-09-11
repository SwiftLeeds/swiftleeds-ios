import Foundation

/// A company sponsoring the conference.
///
/// A read model: nothing writes one, and it guards no invariant. It is shaped
/// for the screen that shows it.
public struct Sponsor: Equatable, Hashable, Identifiable, Sendable {
    public let id: SponsorID
    public let name: String
    public let subtitle: String
    public let level: SponsorLevel

    /// Absent when the server sent nothing usable. The logo is decorative, so a
    /// bad one costs an image rather than the whole list.
    public let logoURL: URL?

    /// Absent when the sponsor supplied no link. The server sends an empty
    /// string for this, which is a real state rather than a defect.
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
