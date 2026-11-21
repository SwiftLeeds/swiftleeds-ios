import SwiftUI

/// A type that applies a custom appearance to all photos within a view hierarchy.
///
/// To configure the current photo style for a view hierarchy, use the
/// ``SwiftUI/View/photoStyle(_:)`` modifier.
///
/// ```swift
/// struct FramedPhotoStyle: PhotoStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.content
///             .border(Color.primary)
///     }
/// }
/// ```
///
/// Draw the configuration's content. A style that leaves it out hides the photo.
///
/// A style may read the environment, such as the color scheme.
public protocol PhotoStyle: DynamicProperty {
    /// A view that represents the body of a photo.
    associatedtype Body: View

    /// The properties of a photo.
    typealias Configuration = PhotoStyleConfiguration

    /// Creates a view that represents the body of a photo.
    ///
    /// The system calls this method for each ``Photo`` instance in a view
    /// hierarchy where this style is the current photo style.
    ///
    /// - Parameter configuration: The properties of the photo.
    /// - Returns: A view that represents the body of a photo.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
