import SwiftUI

extension Shape where Self == ConcentricRectangle {
    /// A rectangle inside a rounded container, whose corners follow the container's and are
    /// never square.
    ///
    /// All four corners take the same radius. Use it inside a view that sets a container shape.
    public static var nested: Self {
        ConcentricRectangle(
            corners: .concentric(minimum: .fixed(CGFloat(CornerRadiusLevel.points12))),
            isUniform: true,
        )
    }
}
