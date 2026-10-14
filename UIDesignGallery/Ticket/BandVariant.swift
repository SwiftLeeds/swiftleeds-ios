/// Whether a role band draws its role's texture.
enum BandVariant: String, Equatable, Hashable, Sendable {
    /// A flat color with no texture.
    case plain

    /// A flat color with the role's texture faint behind the label.
    case patterned
}
