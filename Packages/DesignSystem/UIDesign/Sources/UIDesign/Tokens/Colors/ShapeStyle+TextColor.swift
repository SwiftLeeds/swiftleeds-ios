import SwiftUI

#if os(iOS)
import UIKit
#endif

/// The styles text draws in, from most to least prominent.
extension ShapeStyle where Self == HierarchicalShapeStyle {
    /// The main text on a surface.
    public static var text: HierarchicalShapeStyle { .primary }

    /// Text that supports the main text.
    public static var secondaryText: HierarchicalShapeStyle { .secondary }
}

/// The colors text draws in, from most to least prominent.
extension ShapeStyle where Self == Color {
    // swiftlint:disable no_magic_numbers - the sRGB values of the watchOS tokens are defined here
    /// Text that is present but not meant to be read yet.
    public static var tertiaryText: Color {
        #if os(iOS)
        Color(.tertiaryLabel)
        #elseif os(watchOS)
        Color(.sRGB, red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.298)
        #else
        Color(.tertiaryLabelColor)
        #endif
    }

    /// Text in a control the person can't use right now.
    public static var disabledText: Color {
        #if os(iOS)
        Color(.quaternaryLabel)
        #elseif os(watchOS)
        Color(.sRGB, red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.157)
        #else
        Color(.quaternaryLabelColor)
        #endif
    }
    // swiftlint:enable no_magic_numbers
}

extension ShapeStyle where Self == AnyShapeStyle {
    /// The style of the initials in an avatar's fallback.
    static var avatarInitials: AnyShapeStyle {
        AnyShapeStyle(HierarchicalShapeStyle.text.opacity(.initials))
    }
}

/// The color of text on the brand fill.
extension ShapeStyle where Self == BrandShapeStyle {
    /// Text on a brand colored fill.
    ///
    /// It reaches 4.5:1 against ``brand`` in every appearance.
    public static var onBrand: BrandShapeStyle { BrandShapeStyle(role: .onBrand) }
}
