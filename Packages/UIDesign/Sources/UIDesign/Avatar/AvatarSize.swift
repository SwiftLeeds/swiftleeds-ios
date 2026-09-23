import CoreGraphics

/// The diameter of an avatar.
///
/// Each value is a base size at the default text size. Pass it through `@ScaledMetric` so the
/// shape grows with the text beside it. A frame fixed to the raw value clips its content at the
/// accessibility text sizes.
public enum AvatarSize {
    public static let small: CGFloat = 28
    public static let medium: CGFloat = 40
    public static let large: CGFloat = 56
    public static let xLarge: CGFloat = 80
}
