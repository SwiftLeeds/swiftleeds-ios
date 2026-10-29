import SwiftUI

extension Shape where Self == ConcentricRectangle {
    /// A rectangle whose corners follow its container's and are never square.
    ///
    /// All four corners take the same radius. With no container shape around it, its corners
    /// take the smallest radius.
    public static var nested: Self {
        ConcentricRectangle(
            corners: .concentric(minimum: .fixed(CGFloat(CornerRadiusLevel.points12))),
            isUniform: true,
        )
    }
}
