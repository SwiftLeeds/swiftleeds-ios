import SwiftUI

extension View {
    /// Removes the selected trait that SwiftUI gives some status symbols.
    ///
    /// - Returns: A view that has no selected trait.
    func accessibilityStatusTraits() -> some View {
        accessibilityRemoveTraits(.isSelected)
    }
}
