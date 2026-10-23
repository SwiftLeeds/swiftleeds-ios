/// A point on the globe, as a latitude and a longitude in degrees.
public struct Coordinate: Equatable, Hashable, Sendable {
    /// The reason two numbers cannot become a coordinate.
    public enum ParsingError: Error, Equatable {
        /// A latitude outside -90 to 90 degrees.
        case latitudeOutOfRange

        /// A longitude outside -180 to 180 degrees.
        case longitudeOutOfRange
    }

    /// The largest latitude in degrees, at the north pole.
    private static let maxLatitude: Double = 90

    /// The largest longitude in degrees, at the antimeridian.
    private static let maxLongitude: Double = 180

    /// The latitudes a coordinate accepts.
    private static let latitudes = -maxLatitude...maxLatitude

    /// The longitudes a coordinate accepts.
    private static let longitudes = -maxLongitude...maxLongitude

    /// The latitude in degrees, positive north of the equator.
    public let latitude: Double

    /// The longitude in degrees, positive east of the prime meridian.
    public let longitude: Double

    /// Creates a coordinate, refusing a latitude or longitude out of range.
    /// - Parameters:
    ///   - latitude: The latitude in degrees, from -90 to 90.
    ///   - longitude: The longitude in degrees, from -180 to 180.
    /// - Throws: ``ParsingError/latitudeOutOfRange`` when the latitude is out
    ///   of range, or else ``ParsingError/longitudeOutOfRange`` when the
    ///   longitude is.
    public init(latitude: Double, longitude: Double) throws(ParsingError) {
        guard Self.latitudes.contains(latitude) else { throw .latitudeOutOfRange }
        guard Self.longitudes.contains(longitude) else { throw .longitudeOutOfRange }

        self.latitude = latitude
        self.longitude = longitude
    }
}
