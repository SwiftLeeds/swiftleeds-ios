#if os(watchOS)
import SwiftUI

extension Color.Resolved {
    /// Returns the largest difference in one component between this color and another.
    ///
    /// - Parameter other: The color to compare with.
    /// - Returns: The largest absolute difference across red, green, blue and opacity.
    func largestDifference(from other: Color.Resolved) -> Float {
        max(
            abs(red - other.red),
            abs(green - other.green),
            abs(blue - other.blue),
            abs(opacity - other.opacity),
        )
    }
}
#endif
