import SwiftUI

#if os(iOS)
import UIKit
#endif

/// The colors a border or a divider draws in.
extension ShapeStyle where Self == Color {
    // swiftlint:disable no_magic_numbers - the sRGB values of the watchOS tokens are defined here
    /// A border that lets the surface show through.
    public static var border: Color {
        #if os(iOS)
        Color(.separator)
        #elseif os(watchOS)
        Color(.sRGB, red: 84 / 255, green: 84 / 255, blue: 88 / 255, opacity: 0.5)
        #else
        Color(.separatorColor)
        #endif
    }

    /// A solid border, for where content must not show through.
    public static var opaqueBorder: Color {
        #if os(iOS)
        Color(.opaqueSeparator)
        #elseif os(watchOS)
        Color(.sRGB, red: 42 / 255, green: 42 / 255, blue: 44 / 255, opacity: 1)
        #else
        Color(.gridColor)
        #endif
    }
    // swiftlint:enable no_magic_numbers

    /// The color of an avatar's outline.
    static var avatarOutline: Color { .tertiaryText }
}
