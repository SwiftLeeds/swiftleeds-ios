import SwiftUI

#if os(iOS)
import UIKit
#endif

/// The colors a border or a divider draws in.
extension ShapeStyle where Self == Color {
    /// A border that lets the surface show through.
    public static var border: Color {
        #if os(iOS)
        Color(.separator)
        #else
        Color(.separatorColor)
        #endif
    }

    /// A solid border, for where content must not show through.
    public static var opaqueBorder: Color {
        #if os(iOS)
        Color(.opaqueSeparator)
        #else
        Color(.gridColor)
        #endif
    }
}
