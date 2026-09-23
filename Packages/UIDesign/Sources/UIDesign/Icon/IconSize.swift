import CoreGraphics

/// The side of the square an icon draws in.
///
/// Each value is a base size at the default text size. Pass it through `@ScaledMetric` so the
/// frame grows with the text beside it. A frame fixed to the raw value clips the symbol at the
/// accessibility text sizes.
public enum IconSize {
    public static let xSmall: CGFloat = 12
    public static let small: CGFloat = 16
    public static let medium: CGFloat = 20
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32

    /// Also the smallest comfortable touch target.
    public static let xxLarge: CGFloat = 44
}
