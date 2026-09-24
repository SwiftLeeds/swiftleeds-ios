import SwiftUI

/// A view that stands in for a destination whose design is still to come.
struct NotYetDesigned: View {
    /// The destination this view stands in for.
    let destination: GalleryTab

    var body: some View {
        ContentUnavailableView(
            destination.title,
            systemImage: destination.symbol,
            description: Text("This screen is not designed yet.")
        )
    }
}
