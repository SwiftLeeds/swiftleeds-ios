import SwiftUI

/// The style a border or a divider draws in.
extension ShapeStyle where Self == SeparatorShapeStyle {
    /// A border that lets the surface show through.
    public static var border: SeparatorShapeStyle { .separator }
}

/// The style an avatar draws its outline in.
extension ShapeStyle where Self == HierarchicalShapeStyle {
    /// The style of an avatar's outline.
    static var avatarOutline: HierarchicalShapeStyle { .tertiaryText }
}
