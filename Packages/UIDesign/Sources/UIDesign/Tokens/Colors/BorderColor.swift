import SwiftUI

/// The colours a border or a divider is drawn in.
public extension ShapeStyle where Self == Color {
    /// A divider between rows, or the edge of a card. Lets the surface show through.
    static var borderPrimary: Color {
        #if os(iOS)
        Color(.separator)
        #else
        Color(.separatorColor)
        #endif
    }

    /// A solid divider, for where content must not show through.
    static var borderSecondary: Color {
        #if os(iOS)
        Color(.opaqueSeparator)
        #else
        Color(.gridColor)
        #endif
    }
}
