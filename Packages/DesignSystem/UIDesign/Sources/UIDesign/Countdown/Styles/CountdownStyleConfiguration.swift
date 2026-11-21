import SwiftUI

/// The properties of a countdown.
public struct CountdownStyleConfiguration {
    /// A type-erased label view of a countdown.
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

    /// The words that say how long is left.
    public let label: Label

    /// Creates the properties of a countdown, erasing the label's type.
    ///
    /// - Parameter label: The view showing the time left.
    @MainActor
    init(label: some View) {
        self.label = Label(label)
    }
}
