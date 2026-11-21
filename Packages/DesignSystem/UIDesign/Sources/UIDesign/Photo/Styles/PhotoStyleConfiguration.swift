import SwiftUI

/// The properties of a photo.
public struct PhotoStyleConfiguration {
    /// A type-erased content view of a photo.
    public struct Content: View {
        /// The erased view this content draws.
        private let _body: () -> AnyView

        /// Creates a type-erased content view.
        ///
        /// - Parameter body: The view the content draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A view that shows the photo's picture, or its fallback.
    public let content: Content

    /// Creates the properties of a photo, erasing the content's type.
    ///
    /// - Parameter content: A view that shows the photo's picture, or its fallback.
    @MainActor
    init(content: some View) {
        self.content = Content(content)
    }
}
