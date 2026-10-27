import SwiftUI

#if os(iOS)
import UIKit
#endif

/// The colors text draws in, from most to least prominent.
extension ShapeStyle where Self == Color {
    /// The main text on a surface.
    public static var text: Color { .primary }

    /// Text that supports the main text.
    public static var secondaryText: Color { .secondary }

    /// Text that is present but not meant to be read yet.
    public static var tertiaryText: Color {
        #if os(iOS)
        Color(.tertiaryLabel)
        #else
        Color(.tertiaryLabelColor)
        #endif
    }

    /// Text in a control the person can't use right now.
    public static var disabledText: Color {
        #if os(iOS)
        Color(.quaternaryLabel)
        #else
        Color(.quaternaryLabelColor)
        #endif
    }
}

/// The color of text on the brand fill.
extension ShapeStyle where Self == BrandShapeStyle {
    /// Text on a brand colored fill.
    ///
    /// It reaches 4.5:1 against ``brand`` in every appearance.
    public static var onBrand: BrandShapeStyle { BrandShapeStyle(role: .onBrand) }
}
