import SwiftUI

/// The colours text is drawn in, from most to least prominent.
///
/// Never carry meaning in colour alone. Pair it with a word or a symbol.
public extension ShapeStyle where Self == Color {
    /// The main text on a surface.
    static var textPrimary: Color { .primary }

    /// Supporting text, such as a subtitle or metadata.
    static var textSecondary: Color { .secondary }

    /// Text that is present but not being read, such as a placeholder.
    static var textTertiary: Color {
        #if os(iOS)
        Color(.tertiaryLabel)
        #else
        Color(.tertiaryLabelColor)
        #endif
    }

    /// Text in a control the person cannot use right now.
    static var textDisabled: Color {
        #if os(iOS)
        Color(.quaternaryLabel)
        #else
        Color(.quaternaryLabelColor)
        #endif
    }

    /// Text drawn on a brand coloured fill. It does not flip with the appearance, because the
    /// fill underneath does not either.
    static var textOnBrand: Color { .white }
}
