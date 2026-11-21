import SwiftUI

/// A type that applies a custom appearance to all logos within a view hierarchy.
///
/// To configure the current logo style for a view hierarchy, use the
/// ``SwiftUI/View/logoStyle(_:)`` modifier.
///
/// ```swift
/// struct PlainLogoStyle: LogoStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.content
///     }
/// }
/// ```
///
/// Draw the configuration's content. A style that leaves it out hides the logo's mark.
///
/// When a logo is redacted, its content is a plain gray fill in place of the mark. A style
/// that insets its content draws that fill at full size, so it covers the whole logo.
///
/// A style may read the environment, such as the color scheme or the Dynamic Type size.
public protocol LogoStyle: DynamicProperty {
    /// A view that represents the body of a logo.
    associatedtype Body: View

    /// The properties of a logo.
    typealias Configuration = LogoStyleConfiguration

    /// Creates a view that represents the body of a logo.
    ///
    /// The system calls this method for each ``Logo`` instance in a view
    /// hierarchy where this style is the current logo style.
    ///
    /// - Parameter configuration: The properties of the logo.
    /// - Returns: A view that represents the body of a logo.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
