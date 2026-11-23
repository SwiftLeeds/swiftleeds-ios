#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct RingedAvatarStyleSnapshotTests {
    /// A made-up person whose initials differ.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// Every size, smallest first.
    private static let sizes: [AvatarSize] = [.small, .medium, .large, .xLarge]

    /// Checks every size, with and without a status, because the mark sits over the ring.
    @Test func ringedStyle() {
        let view = VStack(alignment: .leading, spacing: Spacing.lg) {
            row(status: nil)
            row(status: AvatarStatus("Checked in"))
        }
        .avatarStyle(.ringed)
        .avatarRingPalette(.blue)
        .padding(Spacing.lg)

        assertSnapshots(of: view)
    }

    /// Returns a row of every size with initials.
    ///
    /// - Parameter status: The state to show on each avatar, if any.
    /// - Returns: A row of four avatars, smallest first.
    private func row(status: AvatarStatus?) -> some View {
        HStack(alignment: .bottom, spacing: Spacing.lg) {
            ForEach(Self.sizes, id: \.self) { size in
                Avatar(url: nil, size: size, status: status, fallback: .initials(Self.name))
            }
        }
    }
}
#endif
