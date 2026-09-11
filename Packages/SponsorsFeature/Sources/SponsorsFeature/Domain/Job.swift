import Foundation

/// A vacancy a sponsor is advertising.
public struct Job: Equatable, Hashable, Identifiable, Sendable {
    public let id: JobID
    public let title: String
    public let details: String
    public let location: String

    /// Where to apply. Absent when the posting carries no usable link.
    public let url: URL?

    public init(id: JobID, title: String, details: String, location: String, url: URL?) {
        self.id = id
        self.title = title
        self.details = details
        self.location = location
        self.url = url
    }
}
