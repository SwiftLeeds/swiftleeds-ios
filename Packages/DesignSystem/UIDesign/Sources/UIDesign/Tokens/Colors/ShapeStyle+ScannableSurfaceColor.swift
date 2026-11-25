#if !os(watchOS)
import SwiftUI

extension ShapeStyle where Self == BrandShapeStyle {
    /// The plate a scanner reads a code from.
    ///
    /// It stays light in every appearance, so black marks on it scan. It reads the brand's
    /// ``Brand/scannableSurface``: on iOS, dark mode at standard contrast gives the light
    /// secondary surface, every other appearance gives the light surface, and on macOS contrast
    /// has no effect.
    package static var scannableSurface: BrandShapeStyle { BrandShapeStyle(role: .scannableSurface) }
}
#endif
