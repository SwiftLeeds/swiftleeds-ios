import SwiftUI

/// The colors text draws in, from most to least prominent.
extension ShapeStyle where Self == Color {
    /// The main text on a surface.
    public static var textPrimary: Color { .primary }

    /// Text that supports the main text.
    public static var textSecondary: Color { .secondary }

    /// Text that is present but not meant to be read yet.
    public static var textTertiary: Color {
        #if os(iOS)
        Color(.tertiaryLabel)
        #else
        Color(.tertiaryLabelColor)
        #endif
    }

    /// Text in a control the person can't use right now.
    public static var textDisabled: Color {
        #if os(iOS)
        Color(.quaternaryLabel)
        #else
        Color(.quaternaryLabelColor)
        #endif
    }

    /// Text on a brand colored fill.
    ///
    /// It doesn't change with the appearance, because the fill beneath it doesn't either.
    public static var textOnBrand: Color { .white }
}
