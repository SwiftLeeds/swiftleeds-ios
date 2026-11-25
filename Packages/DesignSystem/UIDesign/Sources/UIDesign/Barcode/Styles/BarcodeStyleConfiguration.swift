#if canImport(CoreImage)
import SwiftUI

/// The properties of a barcode.
public struct BarcodeStyleConfiguration {
    /// A type-erased content view of a barcode.
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

    /// A view that shows the barcode's symbol.
    public let content: Content

    /// Creates the properties of a barcode, erasing the content's type.
    ///
    /// - Parameter content: The view showing the barcode's symbol.
    @MainActor
    init(content: some View) {
        self.content = Content(content)
    }
}
#endif
