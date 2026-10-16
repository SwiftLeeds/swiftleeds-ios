import Foundation

/// A place near the conference.
public struct Location: Equatable, Hashable, Identifiable, Sendable {
    public let id: LocationID

    /// The place's name.
    public let name: String

    /// The place's website.
    ///
    /// Absent when the place has no usable web address.
    public let websiteURL: URL?

    /// The place's location on the map.
    public let coordinate: Coordinate

    /// Creates a place.
    public init(id: LocationID, name: String, websiteURL: URL?, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.websiteURL = websiteURL
        self.coordinate = coordinate
    }
}
