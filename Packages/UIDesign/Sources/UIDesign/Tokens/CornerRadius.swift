import CoreGraphics

/// The radius of a rounded corner.
///
/// Match the step to the size of the shape, so the curve looks the same weight at every size.
public enum CornerRadius {
    /// A square corner.
    public static let none: CGFloat = 0

    /// A badge or a tag.
    public static let small: CGFloat = 8

    /// A row or a tile.
    public static let medium: CGFloat = 12

    /// A card.
    public static let large: CGFloat = 16

    /// A sheet or a full width panel.
    public static let xLarge: CGFloat = 24

    /// A fully rounded end. `RoundedRectangle` clamps this to half the shorter side.
    public static let full: CGFloat = .infinity
}
