#if os(iOS)
import AboutUI
import Testing

@MainActor
@Suite struct CompactActionItemSnapshotTests {
    @Test func twoLineTitle() {
        let view = CompactActionItem(
            icon: "exclamationmark.triangle.fill",
            title: "Report a\nProblem",
            accessibilityHint: "Opens a form to report a problem",
            action: {}
        )

        assertGridCellSnapshots(of: view, columns: 3)
    }
}
#endif
