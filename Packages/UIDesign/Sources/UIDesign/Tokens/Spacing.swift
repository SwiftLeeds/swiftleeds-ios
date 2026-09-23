import CoreGraphics

/// The space between elements, on a four point grid.
///
/// Use the smallest step that separates two things clearly. A bigger step means less related.
public enum Spacing {
    /// Between parts of one element, such as a symbol and its label.
    public static let xxSmall: CGFloat = 2

    /// Between lines that read as one block.
    public static let xSmall: CGFloat = 4

    /// Between related elements in a group.
    public static let small: CGFloat = 8

    /// Between groups inside one section.
    public static let medium: CGFloat = 12

    /// From a container edge to its content.
    public static let large: CGFloat = 16

    /// Between sections.
    public static let xLarge: CGFloat = 24

    /// Between the major parts of a screen.
    public static let xxLarge: CGFloat = 32
}
