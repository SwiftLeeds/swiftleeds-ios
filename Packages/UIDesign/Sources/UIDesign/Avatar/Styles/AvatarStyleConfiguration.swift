import SwiftUI

/// The properties of an avatar.
public struct AvatarStyleConfiguration {
    /// A type-erased content view of an avatar.
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

    /// A type-erased status view of an avatar.
    public struct Status: View {
        /// The erased view this status draws.
        private let _body: () -> AnyView

        /// Creates a type-erased status view.
        ///
        /// - Parameter body: The view the status draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// The photo, or the view standing in for it.
    public let content: Content

    /// The diameter to draw at. The text size has already scaled it.
    public let size: AvatarSize

    /// The state to show, drawn and ready to place. Where it goes is the
    /// style's choice.
    public let status: Status?

    /// Creates the properties of an avatar, erasing each view's type.
    ///
    /// - Parameters:
    ///   - content: The view showing the person.
    ///   - size: The diameter to draw at.
    ///   - status: The view marking the person's state, if any.
    @MainActor
    init(content: some View, size: AvatarSize, status: (some View)?) {
        self.content = Content(content)
        self.size = size
        self.status = status.map(Status.init)
    }
}
