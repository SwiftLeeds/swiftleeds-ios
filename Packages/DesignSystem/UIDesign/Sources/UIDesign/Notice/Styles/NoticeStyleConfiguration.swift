import SwiftUI

/// The properties of a notice.
public struct NoticeStyleConfiguration {
    /// A type-erased title view of a notice.
    public struct Title: View {
        /// The erased view this title draws.
        private let _body: () -> AnyView

        /// Creates a type-erased title view.
        ///
        /// - Parameter body: The view the title draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased icon view of a notice.
    public struct Icon: View {
        /// The erased view this icon draws.
        private let _body: () -> AnyView

        /// Creates a type-erased icon view.
        ///
        /// - Parameter body: The view the icon draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        /// The icon, hidden from VoiceOver.
        public var body: some View { _body().accessibilityHidden(true) }
    }

    /// A type-erased description view of a notice.
    public struct Description: View {
        /// The erased view this description draws.
        private let _body: () -> AnyView

        /// Creates a type-erased description view.
        ///
        /// - Parameter body: The view the description draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased actions view of a notice.
    public struct Actions: View {
        /// The erased view these actions draw.
        private let _body: () -> AnyView

        /// Creates a type-erased actions view.
        ///
        /// - Parameter body: The view the actions draw.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A short name for the condition.
    public let title: Title

    /// A symbol that illustrates the condition, which VoiceOver skips.
    public let icon: Icon

    /// A sentence that explains the condition.
    public let description: Description

    /// The controls that resolve the condition.
    public let actions: Actions

    /// Creates the properties of a notice, erasing the type of each part.
    ///
    /// - Parameters:
    ///   - title: The view showing the notice's title.
    ///   - icon: The view showing the notice's icon.
    ///   - description: The view showing the notice's description.
    ///   - actions: The view holding the notice's actions.
    @MainActor
    init(title: some View, icon: some View, description: some View, actions: some View) {
        self.title = Title(title)
        self.icon = Icon(icon)
        self.description = Description(description)
        self.actions = Actions(actions)
    }
}
