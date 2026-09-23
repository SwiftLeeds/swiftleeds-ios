#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite struct AvatarSnapshotTests {
    @Test func sizes() {
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            avatar(size: AvatarSize.small)
            avatar(size: AvatarSize.medium)
            avatar(size: AvatarSize.large)
            avatar(size: AvatarSize.xLarge)
        }

        assertSnapshots(of: view)
    }

    // A flat fill, so this suite measures the shape and the size and nothing else.
    private func avatar(size: CGFloat) -> some View {
        Avatar(url: nil, size: size) {
            Color.secondarySurface
        }
    }
}
#endif
