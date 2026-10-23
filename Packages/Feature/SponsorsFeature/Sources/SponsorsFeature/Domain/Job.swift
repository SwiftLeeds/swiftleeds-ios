import Foundation

/// A vacancy a sponsor is advertising.
public struct Job: Equatable, Hashable, Identifiable, Sendable {
    public let id: JobID

    /// The job's title.
    public let title: String

    /// A description of the job.
    public let details: String

    /// Where the job is based.
    public let location: String

    /// Where to apply. Absent when the posting has no link.
    public let url: URL?

    /// Creates a job.
    public init(id: JobID, title: String, details: String, location: String, url: URL?) {
        self.id = id
        self.title = title
        self.details = details
        self.location = location
        self.url = url
    }
}
