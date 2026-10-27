import SwiftUI

/// The backgrounds a screen is built from.
///
/// Each keeps the lightness of Apple's background and takes a faint hint of the brand in the
/// environment.
extension ShapeStyle where Self == BrandShapeStyle {
    /// The main background of an interface.
    public static var surface: BrandShapeStyle { BrandShapeStyle(role: .surface) }

    /// The background of content layered on top of the main background.
    public static var secondarySurface: BrandShapeStyle { BrandShapeStyle(role: .secondarySurface) }

    /// The background of content layered on top of secondary backgrounds.
    public static var tertiarySurface: BrandShapeStyle { BrandShapeStyle(role: .tertiarySurface) }
}
