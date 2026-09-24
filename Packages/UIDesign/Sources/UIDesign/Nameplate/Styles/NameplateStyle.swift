import SwiftUI

/// A type that applies a custom appearance to all nameplates within a view.
///
/// To configure the current nameplate style for a view hierarchy, use the
/// ``SwiftUI/View/nameplateStyle(_:)`` modifier.
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
/// Draw all three of the configuration's views. One that a style leaves out
/// reaches neither the screen nor VoiceOver, because a nameplate reads as a
/// single element.
///
/// A style may read the environment, so it can answer the appearance and the
/// text size.
public protocol NameplateStyle: DynamicProperty {
    /// A view that represents the body of a nameplate.
    associatedtype Body: View

    /// The properties of a nameplate.
    typealias Configuration = NameplateStyleConfiguration

    /// Creates a view that represents the body of a nameplate.
    ///
    /// The system calls this method for each nameplate instance in a view
    /// hierarchy where this style is the current nameplate style.
    ///
    /// - Parameter configuration: The properties of the nameplate.
    /// - Returns: A view that has behavior and appearance that enables it to
    ///   function as a nameplate.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
