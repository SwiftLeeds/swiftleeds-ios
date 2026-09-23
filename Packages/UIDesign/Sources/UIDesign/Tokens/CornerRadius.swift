import CoreGraphics

/// The radius of a rounded corner.
public enum CornerRadius {
    public static let none: CGFloat = 0
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
    public static let xLarge: CGFloat = 24

    /// A fully rounded end. `RoundedRectangle` clamps this to half the shorter side.
    public static let full: CGFloat = .infinity
}
