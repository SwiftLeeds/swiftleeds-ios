import SwiftUI
import UIDesign

/// A view that shows when a session starts and what kind it is, if known.
struct SessionBadges: View {
    /// The session the badges describe.
    let session: SampleSession

    var body: some View {
        HStack(spacing: .small) {
            if let startsIn = session.startsIn {
                MockBadge(text: startsIn, tint: .success)
            }

            if let kind = session.kind {
                MockNeutralBadge(text: kind)
            }
        }
    }
}
