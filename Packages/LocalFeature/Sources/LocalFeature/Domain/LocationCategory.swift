/// A kind of place near the conference, such as food or coffee, with the places of that kind.
public struct LocationCategory: Equatable, Hashable, Identifiable, Sendable {
    public let id: LocationCategoryID
    public let name: String

    /// The backend's name for the symbol that stands for the category.
    public let symbolName: String

    public let locations: [Location]

    public init(id: LocationCategoryID, name: String, symbolName: String, locations: [Location]) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.locations = locations
    }
}
