import SwiftUI

/// The properties of a nameplate.
public struct NameplateStyleConfiguration {
    /// A type-erased nameplate title view.
    public struct Title: View {
        /// The erased view this title draws.
        private let _body: () -> AnyView

        /// Creates a title from a view.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased nameplate detail view.
    public struct Detail: View {
        /// The erased view this detail draws.
        private let _body: () -> AnyView

        /// Creates a detail from a view.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased nameplate icon view.
    public struct Icon: View {
        /// The erased view this icon draws.
        private let _body: () -> AnyView

        /// Creates an icon from a view.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// What the subject is called.
    public let title: Title

    /// One more line about the subject. It draws nothing when the caller gave
    /// none.
    public let detail: Detail

    /// The picture of the subject. It keeps the size the caller gave it.
    public let icon: Icon

    /// Creates a configuration.
    @MainActor
    init(title: some View, detail: some View, icon: some View) {
        self.title = Title(title)
        self.detail = Detail(detail)
        self.icon = Icon(icon)
    }
}
