#if !os(watchOS)
import SwiftUI

extension ShapeStyle where Self == BrandShapeStyle {
    /// The plate a scanner reads a code from.
    ///
    /// It stays light in every appearance, so black marks on it scan.
    package static var scannableSurface: BrandShapeStyle { BrandShapeStyle(role: .scannableSurface) }
}
#endif
