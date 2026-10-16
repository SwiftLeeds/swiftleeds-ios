import SwiftUI

/// The properties of a nameplate.
public struct NameplateStyleConfiguration {
    /// A type-erased title view of a nameplate.
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

    /// A type-erased detail view of a nameplate.
    public struct Detail: View {
        /// The erased view this detail draws.
        private let _body: () -> AnyView

        /// Creates a type-erased detail view.
        ///
        /// - Parameter body: The view the detail draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A type-erased icon view of a nameplate.
    public struct Icon: View {
        /// The erased view this icon draws.
        private let _body: () -> AnyView

        /// Creates a type-erased icon view.
        ///
        /// - Parameter body: The view the icon draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A name for the subject.
    public let title: Title

    /// A description of the subject. It draws nothing when the caller gave
    /// none.
    public let detail: Detail

    /// A pictorial representation of the subject. It keeps the size it was
    /// given.
    public let icon: Icon

    /// Creates the properties of a nameplate, erasing each view's type.
    ///
    /// - Parameters:
    ///   - title: The view naming the subject.
    ///   - detail: The view describing the subject.
    ///   - icon: The view picturing the subject.
    @MainActor
    init(title: some View, detail: some View, icon: some View) {
        self.title = Title(title)
        self.detail = Detail(detail)
        self.icon = Icon(icon)
    }
}
