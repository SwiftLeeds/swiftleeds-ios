import SwiftUI

/// The properties of an avatar group.
public struct AvatarGroupStyleConfiguration {
    /// A type-erased content view of an avatar group.
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

    /// A type-erased overflow view of an avatar group.
    public struct Overflow: View {
        /// The erased view this overflow draws.
        private let _body: () -> AnyView

        /// Creates a type-erased overflow view.
        ///
        /// - Parameter body: The view the overflow draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// The avatars to show.
    public let content: Content

    /// The count of the people who do not fit, drawn and ready to place.
    ///
    /// It is `nil` when every person fits. Where it goes is the style's choice.
    public let overflow: Overflow?

    /// Creates the properties of an avatar group, erasing each view's type.
    ///
    /// - Parameters:
    ///   - content: The avatars to show.
    ///   - overflow: The view counting the people who do not fit, if any.
    @MainActor
    init(content: some View, overflow: (some View)?) {
        self.content = Content(content)
        self.overflow = overflow.map(Overflow.init)
    }
}
