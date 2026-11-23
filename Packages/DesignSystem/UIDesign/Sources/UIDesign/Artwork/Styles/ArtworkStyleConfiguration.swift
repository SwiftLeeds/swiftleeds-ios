import SwiftUI

/// The properties of an artwork.
public struct ArtworkStyleConfiguration {
    /// A type-erased symbol view of an artwork.
    public struct Symbol: View {
        /// The erased view this symbol draws.
        private let _body: () -> AnyView

        /// Creates a type-erased symbol view.
        ///
        /// - Parameter body: The view the symbol draws.
        init(_ body: some View) {
            _body = { AnyView(body) }
        }

        public var body: some View { _body() }
    }

    /// A view that shows the artwork's symbol, fitted to the space it is given.
    public let symbol: Symbol

    /// The colors the artwork draws with.
    ///
    /// Compare it with a palette, such as `.teal`, to choose a look.
    public let palette: Artwork.Palette

    /// Creates the properties of an artwork, erasing the symbol's type.
    ///
    /// - Parameters:
    ///   - symbol: A view that shows the artwork's symbol.
    ///   - palette: The colors the artwork draws with.
    @MainActor
    init(symbol: some View, palette: Artwork.Palette) {
        self.symbol = Symbol(symbol)
        self.palette = palette
    }
}
