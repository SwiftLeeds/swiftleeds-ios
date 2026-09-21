#if os(iOS)
import LocalUI
import SharedAssets
import SwiftUI
import Testing

@MainActor
@Suite struct LocalCellSnapshotTests {
    @Test func unselected() {
        let view = LocalCell(label: "Food", imageName: "takeoutbag.and.cup.and.straw.fill")

        assertCellSnapshots(of: view)
    }

    @Test func selected() {
        let view = LocalCell(
            label: "Drinks",
            imageName: "wineglass.fill",
            foregroundColor: .accent
        )

        assertCellSnapshots(of: view)
    }

    @Test func longLabel() {
        let view = LocalCell(
            label: "Independent coffee shops near the venue",
            imageName: "cup.and.saucer.fill"
        )

        assertCellSnapshots(of: view)
    }
}
#endif
