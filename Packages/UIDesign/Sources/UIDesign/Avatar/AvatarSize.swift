import CoreGraphics

/// The diameter of an avatar.
///
/// Each value is the size at the default text size. Scale it with `@ScaledMetric`, or the initials
/// outgrow the shape and clip at the accessibility text sizes.
public enum AvatarSize {
    /// One of several in a row, such as the speakers on a session.
    public static let small: CGFloat = 28

    /// Identifies the subject of a list row.
    public static let medium: CGFloat = 40

    /// In a toolbar, or at the head of a card.
    public static let large: CGFloat = 56

    /// Leads a profile screen.
    public static let xLarge: CGFloat = 80
}
