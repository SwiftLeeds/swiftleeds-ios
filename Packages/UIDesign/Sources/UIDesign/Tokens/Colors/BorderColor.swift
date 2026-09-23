import SwiftUI

/// The colours a border or a divider draws in.
public extension ShapeStyle where Self == Color {
    /// A border that lets the surface show through.
    static var borderPrimary: Color {
        #if os(iOS)
        Color(.separator)
        #else
        Color(.separatorColor)
        #endif
    }

    /// A solid border, for where content must not show through.
    static var borderSecondary: Color {
        #if os(iOS)
        Color(.opaqueSeparator)
        #else
        Color(.gridColor)
        #endif
    }
}
