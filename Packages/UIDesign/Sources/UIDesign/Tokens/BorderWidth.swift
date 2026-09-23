import CoreGraphics

/// The width of a border or a divider.
public enum BorderWidth {
    /// A hairline. Draws as one device pixel at a display scale of two or more.
    public static let thin: CGFloat = 0.5

    public static let medium: CGFloat = 1
    public static let thick: CGFloat = 2
}
