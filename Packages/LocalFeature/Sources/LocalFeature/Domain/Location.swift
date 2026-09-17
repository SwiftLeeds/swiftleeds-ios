import Foundation

/// A place near the conference.
public struct Location: Equatable, Hashable, Identifiable, Sendable {
    public let id: LocationID
    public let name: String
    public let websiteURL: URL
    public let coordinate: Coordinate

    public init(id: LocationID, name: String, websiteURL: URL, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.websiteURL = websiteURL
        self.coordinate = coordinate
    }
}
