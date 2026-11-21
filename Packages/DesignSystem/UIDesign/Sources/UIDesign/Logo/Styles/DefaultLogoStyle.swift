import SwiftUI

/// The default logo style.
///
/// Like `DefaultButtonStyle` and `DefaultLabelStyle`, it is reached as ``LogoStyle/automatic``.
public struct DefaultLogoStyle: LogoStyle {
    /// Creates the default logo style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

extension LogoStyle where Self == DefaultLogoStyle {
    /// The default logo style.
    public static var automatic: DefaultLogoStyle { DefaultLogoStyle() }
}
