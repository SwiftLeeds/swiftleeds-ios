import SwiftUI

extension EnvironmentValues {
    /// The logo style applied to the view hierarchy.
    @Entry public var logoStyle: any LogoStyle = .automatic
}

extension View {
    /// Sets the style for logos within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Logo(url: sponsor.logoURL)
    /// }
    /// .logoStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The logo style to apply.
    /// - Returns: A view that uses the given style for the logos within it.
    public func logoStyle(_ style: some LogoStyle) -> some View {
        environment(\.logoStyle, style)
    }
}
