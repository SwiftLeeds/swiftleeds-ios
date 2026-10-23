#if os(iOS)
import SwiftUI
import UIKit

/// The space between the card's edge and its content, in points.
private let cardPadding: CGFloat = 16

extension View {
    // A component has no width of its own, so a reference image needs one given.
    // The background makes the dark reference dark rather than transparent.
    func snapshotCard(width: CGFloat = 360) -> some View {
        frame(width: width, alignment: .leading)
            .padding(cardPadding)
            .background(Color(.systemBackground))
    }
}
#endif
