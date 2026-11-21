import SwiftUI

/// The default countdown style.
///
/// You can also use ``CountdownStyle/automatic`` to construct this style.
public struct DefaultCountdownStyle: CountdownStyle {
    /// Creates the default countdown style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension CountdownStyle where Self == DefaultCountdownStyle {
    /// The default countdown style.
    public static var automatic: DefaultCountdownStyle { DefaultCountdownStyle() }
}
