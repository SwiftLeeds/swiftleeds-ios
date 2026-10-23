/// A kind of place near the conference, such as food or coffee.
public struct LocationCategory: Equatable, Hashable, Identifiable, Sendable {
    public let id: LocationCategoryID

    /// The category's name.
    public let name: String

    /// The backend's name for the symbol that stands for the category.
    public let symbolName: String

    /// The places of this kind.
    public let locations: [Location]

    /// Creates a category.
    public init(id: LocationCategoryID, name: String, symbolName: String, locations: [Location]) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.locations = locations
    }
}
