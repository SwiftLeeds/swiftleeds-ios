import Dependencies
import Foundation

/// Turns the backend's location list into location categories.
package struct LocationCategoryMapper: Sendable {
    /// A value the backend sent could not become part of the model.
    package struct MappingError: Error, Equatable {
        package let location: String
        package let field: LocationCategoryListDTO.LocationDTO.CodingKeys
        package let value: String
    }

    package var map: @Sendable (LocationCategoryListDTO) throws(MappingError) -> [LocationCategory]

    package init(map: @escaping @Sendable (LocationCategoryListDTO) throws(MappingError) -> [LocationCategory]) {
        self.map = map
    }
}

extension LocationCategoryMapper {
    package static let live = LocationCategoryMapper { list throws(MappingError) in
        try list.data.map { dto throws(MappingError) in try category(dto) }
    }

    private static func category(
        _ dto: LocationCategoryListDTO.LocationCategoryDTO
    ) throws(MappingError) -> LocationCategory {
        LocationCategory(
            id: LocationCategoryID(dto.id),
            name: dto.name,
            symbolName: dto.symbolName,
            locations: try dto.locations.map { dto throws(MappingError) in try location(dto) },
        )
    }

    private static func location(_ dto: LocationCategoryListDTO.LocationDTO) throws(MappingError) -> Location {
        Location(
            id: LocationID(dto.id),
            name: dto.name,
            websiteURL: URL(string: dto.url).flatMap { $0.isWebAddress ? $0 : nil },
            coordinate: try coordinate(dto),
        )
    }

    private static func coordinate(_ dto: LocationCategoryListDTO.LocationDTO) throws(MappingError) -> Coordinate {
        do throws(Coordinate.ParsingError) {
            return try Coordinate(latitude: dto.lat, longitude: dto.lon)
        } catch {
            switch error {
            case .latitudeOutOfRange:
                throw MappingError(location: dto.name, field: .lat, value: String(dto.lat))

            case .longitudeOutOfRange:
                throw MappingError(location: dto.name, field: .lon, value: String(dto.lon))
            }
        }
    }
}

extension URL {
    /// A Boolean value indicating whether this is an http or https address
    /// with a host.
    ///
    /// `URL(string:)` accepts "trinityleeds.com" as a relative reference
    /// with no scheme, which a browser cannot open.
    fileprivate var isWebAddress: Bool {
        guard let scheme = scheme?.lowercased(), host != nil else { return false }
        return scheme == "http" || scheme == "https"
    }
}

extension DependencyValues {
    /// The key that stores the location category mapper among the dependency values.
    private enum LocationCategoryMapperKey: DependencyKey {
        static var liveValue: LocationCategoryMapper { .live }
        /// The live mapper, which tests use as it is.
        static var testValue: LocationCategoryMapper { liveValue }
    }

    package var locationCategoryMapper: LocationCategoryMapper {
        get { self[LocationCategoryMapperKey.self] }
        set { self[LocationCategoryMapperKey.self] = newValue }
    }
}
