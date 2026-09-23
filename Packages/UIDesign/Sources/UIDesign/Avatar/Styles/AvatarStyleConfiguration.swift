import SwiftUI

/// What an ``AvatarStyle`` draws.
public struct AvatarStyleConfiguration {
    /// A type-erased avatar content view.
    public struct Content: View {
        private let _body: () -> AnyView

        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased avatar status view.
    public struct Status: View {
        private let _body: () -> AnyView

        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// The photo, or the view standing in for it.
    public let content: Content

    /// The diameter to draw at. The text size has already scaled it.
    public let size: AvatarSize

    /// The state to show, drawn and ready to place. Where it goes is the style's choice.
    public let status: Status?

    @MainActor
    init(content: some View, size: AvatarSize, status: (some View)?) {
        self.content = Content(content)
        self.size = size
        self.status = status.map(Status.init)
    }
}
