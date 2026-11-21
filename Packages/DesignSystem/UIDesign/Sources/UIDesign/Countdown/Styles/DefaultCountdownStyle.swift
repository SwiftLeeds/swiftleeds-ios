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
