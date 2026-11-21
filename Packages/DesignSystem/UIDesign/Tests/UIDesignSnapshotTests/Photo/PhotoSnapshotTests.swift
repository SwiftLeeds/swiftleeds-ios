#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct PhotoSnapshotTests {
    /// A photo with no picture, framed and clipped as a thumbnail, on the base surface.
    private var thumbnail: some View {
        Photo(url: nil)
            .frame(avatarSize: .large)
            .clipShape(RoundedRectangle(cornerRadius: .tile))
            .padding(.lg)
            .background(.surface)
    }

    @Test func whenPhotoHasNoPicture_shouldDrawGreyFill() {
        assertContrastSnapshots(of: thumbnail)
    }

    @Test func whenPhotoHasNoPictureInDarkElevatedSheet_shouldDrawGreyFill() {
        let darkElevated = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        // The snapshot helpers have no elevated variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: thumbnail.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: darkElevated),
            named: "dark-elevated",
        )
    }
}
#endif
