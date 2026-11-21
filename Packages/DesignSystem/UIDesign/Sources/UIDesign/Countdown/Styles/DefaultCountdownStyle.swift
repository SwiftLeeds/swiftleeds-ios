import SwiftUI

/// The default countdown style.
///
/// It draws every digit at the same width, so the text keeps its width while the number
/// changes within the same count of digits.
///
/// You can also use ``CountdownStyle/automatic`` to construct this style.
public struct DefaultCountdownStyle: CountdownStyle {
    /// Creates the default countdown style.
    public init() {}

    /// Creates a view that represents the body of a countdown.
    ///
    /// The system calls this method for each ``Countdown`` instance in a view hierarchy where this
    /// style is the current countdown style.
    ///
    /// - Parameter configuration: The properties of the countdown.
    /// - Returns: A view that represents the body of a countdown.
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .monospacedDigit()
    }
}

extension CountdownStyle where Self == DefaultCountdownStyle {
    /// The default countdown style.
    public static var automatic: DefaultCountdownStyle { DefaultCountdownStyle() }
}
