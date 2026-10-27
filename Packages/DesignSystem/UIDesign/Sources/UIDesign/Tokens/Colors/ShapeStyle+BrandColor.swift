import SwiftUI

/// The conference's own color.
extension ShapeStyle where Self == BrandShapeStyle {
    /// The fill that marks something as ours.
    ///
    /// It is the brand in the environment: orange for SwiftLeeds and purple for KotlinLeeds. Put
    /// ``onBrand`` on it. Do not use it for text: it can fall below 4.5:1 on a light surface.
    public static var brand: BrandShapeStyle { BrandShapeStyle(role: .brand) }
}
