import SwiftUI

/// The properties of a badge.
public struct BadgeStyleConfiguration {
    /// A type-erased label view of a badge.
    public struct Label: View {
        /// The erased view this label draws.
        private let _body: () -> AnyView

        /// Creates a type-erased label view.
        ///
        /// - Parameter body: The view the label draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// The word the badge shows.
    public let label: Label

    /// The colors the badge draws with.
    package let colors: ColorFamily

    /// Creates the properties of a badge, erasing the label's type.
    ///
    /// - Parameters:
    ///   - label: The view showing the badge's word.
    ///   - colors: The colors the badge draws with.
    @MainActor
    init(label: some View, colors: ColorFamily) {
        self.label = Label(label)
        self.colors = colors
    }
}
