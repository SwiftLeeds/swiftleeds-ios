import SwiftUI

/// A view that stands in for a screen whose design is still to come.
///
/// The screen it stands in for carries its own navigation title, so this says
/// only that the design is missing.
struct NotYetDesigned: View {
    /// The SF Symbol that stands for the screen.
    let symbol: String

    /// Creates a stand-in showing one symbol.
    ///
    /// - Parameter symbol: The SF Symbol that stands for the screen.
    init(symbol: String) {
        self.symbol = symbol
    }

    /// Creates a stand-in for one of the gallery's top-level destinations.
    ///
    /// - Parameter destination: The destination this view stands in for.
    init(destination: GalleryTab) {
        self.init(symbol: destination.symbol)
    }

    var body: some View {
        ContentUnavailableView(
            "Not designed yet",
            systemImage: symbol,
            description: Text("This screen is still to come."),
        )
    }
}
