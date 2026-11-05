import SwiftUI

/// The styles text draws in, from most to least prominent.
extension ShapeStyle where Self == HierarchicalShapeStyle {
    /// The main text on a surface.
    public static var text: HierarchicalShapeStyle { .primary }

    /// Text that supports the main text.
    public static var secondaryText: HierarchicalShapeStyle { .secondary }

    /// Text that is present but not meant to be read yet.
    public static var tertiaryText: HierarchicalShapeStyle { .tertiary }

    /// Text in a control the person can't use right now.
    public static var disabledText: HierarchicalShapeStyle { .quaternary }
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
