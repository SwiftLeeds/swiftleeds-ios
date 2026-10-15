/// A point on the globe, as a latitude and a longitude in degrees.
public struct Coordinate: Equatable, Hashable, Sendable {
    /// The reason two numbers cannot become a coordinate.
    public enum ParsingError: Error, Equatable {
        /// A latitude outside -90 to 90 degrees.
        case latitudeOutOfRange

        /// A longitude outside -180 to 180 degrees.
        case longitudeOutOfRange
    }

    /// The latitudes a coordinate accepts.
    private static let latitudes = -90.0...90.0

    /// The longitudes a coordinate accepts.
    private static let longitudes = -180.0...180.0

    /// The latitude in degrees, positive north of the equator.
    public let latitude: Double

    /// The longitude in degrees, positive east of the prime meridian.
    public let longitude: Double

    /// Creates a coordinate, refusing a latitude or longitude out of range.
    /// - Parameters:
    ///   - latitude: The latitude in degrees, from -90 to 90.
    ///   - longitude: The longitude in degrees, from -180 to 180.
    /// - Throws: ``ParsingError/latitudeOutOfRange`` or
    ///   ``ParsingError/longitudeOutOfRange`` when a value is out of range.
    public init(latitude: Double, longitude: Double) throws(ParsingError) {
        guard Self.latitudes.contains(latitude) else { throw .latitudeOutOfRange }
        guard Self.longitudes.contains(longitude) else { throw .longitudeOutOfRange }

        self.latitude = latitude
        self.longitude = longitude
    }
}
