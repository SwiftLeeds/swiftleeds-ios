/// A point on the globe, as a latitude and a longitude in degrees.
public struct Coordinate: Equatable, Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case latitudeOutOfRange
        case longitudeOutOfRange
    }

    private static let latitudes = -90.0...90.0

    public let latitude: Double
    public let longitude: Double

    /// Creates a coordinate from a latitude in -90...90 and a longitude in -180...180.
    public init(latitude: Double, longitude: Double) throws(ParsingError) {
        guard Self.latitudes.contains(latitude) else { throw .latitudeOutOfRange }

        self.latitude = latitude
        self.longitude = longitude
    }
}
