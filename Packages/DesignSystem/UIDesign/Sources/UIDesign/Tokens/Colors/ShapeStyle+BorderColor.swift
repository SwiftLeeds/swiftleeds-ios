import SwiftUI

/// The style a border or a divider draws in.
extension ShapeStyle where Self == SeparatorShapeStyle {
    /// A border that lets the surface show through.
    public static var border: SeparatorShapeStyle { .separator }
}

/// The style of an avatar's outline.
extension ShapeStyle where Self == Color {
    /// The color of an avatar's outline.
    static var avatarOutline: Color { .tertiaryText }
}
