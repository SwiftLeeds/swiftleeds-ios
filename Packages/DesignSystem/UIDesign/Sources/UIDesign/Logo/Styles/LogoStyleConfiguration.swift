import SwiftUI

/// The properties of a logo.
public struct LogoStyleConfiguration {
    /// A type-erased content view of a logo.
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

    /// A view that shows the logo's mark, or its fallback.
    public let content: Content

    /// Creates the properties of a logo, erasing the content's type.
    ///
    /// - Parameter content: The view showing the logo's mark.
    @MainActor
    init(content: some View) {
        self.content = Content(content)
    }
}
