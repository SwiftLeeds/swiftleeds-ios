import SwiftUI

/// A type that applies a custom appearance to all countdowns within a view hierarchy.
///
/// To configure the current countdown style for a view hierarchy, use the
/// ``SwiftUI/View/countdownStyle(_:)`` modifier.
///
/// ```swift
/// struct EmphasizedCountdownStyle: CountdownStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.label
///             .fontWeight(.semibold)
///     }
/// }
/// ```
///
/// Draw the configuration's label. A style that leaves it out hides the time.
public protocol CountdownStyle: DynamicProperty {
    /// A view that represents the body of a countdown.
    associatedtype Body: View

    /// The properties of a countdown.
    typealias Configuration = CountdownStyleConfiguration

    /// Creates a view that represents the body of a countdown.
    ///
    /// The system calls this method for each ``Countdown`` instance in a view
    /// hierarchy where this style is the current countdown style.
    ///
    /// - Parameter configuration: The properties of the countdown.
    /// - Returns: A view that represents the body of a countdown.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
