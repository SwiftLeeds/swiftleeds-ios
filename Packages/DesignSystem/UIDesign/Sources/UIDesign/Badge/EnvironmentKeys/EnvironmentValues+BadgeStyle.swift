import SwiftUI

extension EnvironmentValues {
    /// The badge style applied to the view hierarchy.
    @Entry public var badgeStyle: any BadgeStyle = .automatic
}

extension View {
    /// Sets the style for badges within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Badge("Workshop")
    /// }
    /// .badgeStyle(.tinted)
    /// ```
    ///
    /// - Parameter style: The badge style to apply.
    /// - Returns: A view that uses the given style for the badges within it.
    public func badgeStyle(_ style: some BadgeStyle) -> some View {
        environment(\.badgeStyle, style)
    }
}
