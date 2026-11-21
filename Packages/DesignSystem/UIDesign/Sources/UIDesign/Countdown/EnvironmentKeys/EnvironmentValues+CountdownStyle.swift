import SwiftUI

extension EnvironmentValues {
    /// The countdown style applied to the view hierarchy.
    @Entry public var countdownStyle: any CountdownStyle = .automatic
}

extension View {
    /// Sets the style for countdowns within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Countdown(to: session.start)
    /// }
    /// .countdownStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The countdown style to apply.
    /// - Returns: A view that uses the given style for the countdowns within it.
    public func countdownStyle(_ style: some CountdownStyle) -> some View {
        environment(\.countdownStyle, style)
    }
}
