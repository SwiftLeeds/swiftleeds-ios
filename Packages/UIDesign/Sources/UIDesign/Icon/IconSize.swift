import CoreGraphics

/// The side of the square an icon draws in.
///
/// Each value is the size at the default text size. Scale it with `@ScaledMetric`, or the glyph
/// outgrows its frame and clips at the accessibility text sizes.
public enum IconSize {
    /// Inside a label or a badge.
    public static let xSmall: CGFloat = 12

    /// Beside body text.
    public static let small: CGFloat = 16

    /// In a list row.
    public static let medium: CGFloat = 20

    /// In a toolbar or a tab.
    public static let large: CGFloat = 24

    /// Leading a section.
    public static let xLarge: CGFloat = 32

    /// The whole control, at the smallest touch target.
    public static let xxLarge: CGFloat = 44
}
