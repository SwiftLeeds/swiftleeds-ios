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
            locations: []
        )
    }
}
