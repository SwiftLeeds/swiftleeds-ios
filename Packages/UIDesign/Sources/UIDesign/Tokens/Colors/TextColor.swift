import SwiftUI

/// The colours text draws in, from most to least prominent.
///
/// Don't carry meaning in colour alone. Pair it with a word or a symbol.
public extension ShapeStyle where Self == Color {
    /// The main text on a surface.
    static var textPrimary: Color { .primary }

    /// Text that supports the main text.
    static var textSecondary: Color { .secondary }

    /// Text that is present but not meant to be read yet.
    static var textTertiary: Color {
        #if os(iOS)
        Color(.tertiaryLabel)
        #else
        Color(.tertiaryLabelColor)
        #endif
    }

    /// Text in a control the person can't use right now.
    static var textDisabled: Color {
        #if os(iOS)
        Color(.quaternaryLabel)
        #else
        Color(.quaternaryLabelColor)
        #endif
    }

    /// Text on a brand coloured fill.
    ///
    /// It doesn't change with the appearance, because the fill beneath it doesn't either.
    static var textOnBrand: Color { .white }
}
