#if os(iOS)
import LocalUI
import SwiftUI
import Testing

@MainActor
@Suite struct SectionHeaderSnapshotTests {
    @Test func defaultStyle() {
        let view = SectionHeader(title: "Nearby")

        assertSheetSnapshots(of: view)
    }

    @Test func screenTitleStyle() {
        let view = SectionHeader(
            title: "Local",
            fontStyle: .title2.weight(.semibold),
            foregroundColor: .primary
        )

        assertSheetSnapshots(of: view)
    }
}
#endif
