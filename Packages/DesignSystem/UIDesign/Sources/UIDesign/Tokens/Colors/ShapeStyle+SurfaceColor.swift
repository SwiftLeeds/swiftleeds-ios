import SwiftUI

/// The backgrounds a screen is built from, in three levels of depth.
///
/// Each keeps the lightness of Apple's background and takes a faint hint of the brand in the
/// environment.
extension ShapeStyle where Self == BrandShapeStyle {
    /// The background of a screen.
    public static var surface: BrandShapeStyle { BrandShapeStyle(role: .surface) }

    /// The background of grouped content on a screen.
    public static var secondarySurface: BrandShapeStyle { BrandShapeStyle(role: .secondarySurface) }

    /// The background of an element inside grouped content.
    public static var tertiarySurface: BrandShapeStyle { BrandShapeStyle(role: .tertiarySurface) }
}
