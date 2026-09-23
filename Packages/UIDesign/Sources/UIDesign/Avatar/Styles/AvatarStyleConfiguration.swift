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

    /// The photo, or the view standing in for it.
    public let content: Content

    /// The diameter to draw at. The text size has already scaled it.
    public let size: CGFloat

    /// What to mark the avatar's lower edge with, if anything.
    public let status: AvatarStatus?

    @MainActor
    init(content: some View, size: CGFloat, status: AvatarStatus?) {
        self.content = Content(content)
        self.size = size
        self.status = status
    }
}
