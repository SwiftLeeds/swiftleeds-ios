import CoreGraphics

/// The width of a border or a divider.
public enum BorderWidth {
    /// A hairline. Draws as one device pixel at a display scale of two or more.
    public static let thin: CGFloat = 0.5

    /// The default border for a control or a card.
    public static let medium: CGFloat = 1

    /// Marks a selected or focused element.
    public static let thick: CGFloat = 2
}
