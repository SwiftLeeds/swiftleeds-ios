import SwiftUI

extension EnvironmentValues {
    /// The palette applied to the badges in the view hierarchy.
    @Entry public var badgePalette: BadgePalette = .neutral
}

extension View {
    /// Sets the palette for badges within this view.
    ///
    /// This colors only ``Badge``. It does not color the count that SwiftUI's
    /// `badge(_:)` adds to a list row or a tab.
    ///
    /// ```swift
    /// HStack {
    ///     Badge("Workshop")
    ///     Badge("Sold out")
    /// }
    /// .badgePalette(.teal)
    /// ```
    ///
    /// - Parameter palette: The palette to apply.
    /// - Returns: A view that uses the given palette for the badges within it.
    public func badgePalette(_ palette: BadgePalette) -> some View {
        environment(\.badgePalette, palette)
    }
}
