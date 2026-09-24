import SwiftUI

/// A type that applies a custom appearance to every ``Nameplate`` in a view hierarchy.
///
/// Write one to lay a nameplate out in a way of your own, then set it with
/// ``SwiftUI/View/nameplateStyle(_:)``.
///
/// ```swift
/// struct TrailingDetailNameplateStyle: NameplateStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         HStack {
///             configuration.icon
///             configuration.title
///             Spacer()
///             configuration.detail
///         }
///     }
/// }
/// ```
///
/// Draw all three of the configuration's views. One a style leaves out reaches neither the screen
/// nor VoiceOver, because the nameplate reads as a single element.
///
/// A style may read the environment, so it can answer the appearance and the text size.
public protocol NameplateStyle: DynamicProperty {
    /// A view that represents the body of a nameplate.
    associatedtype Body: View

    /// The properties of a nameplate.
    typealias Configuration = NameplateStyleConfiguration

    /// Draws one nameplate.
    ///
    /// - Parameter configuration: The views to draw.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
