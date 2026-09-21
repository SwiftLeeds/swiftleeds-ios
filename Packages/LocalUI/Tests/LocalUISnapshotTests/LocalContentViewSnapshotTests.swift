#if os(iOS)
import LocalUI
import Testing

@MainActor
@Suite struct LocalContentViewSnapshotTests {
    @Test func loading() {
        let view = LocalContentView(state: .loading, reload: {})

        assertScreenSnapshots(of: view)
    }

    @Test func failed() {
        let view = LocalContentView(state: .failed, reload: {})

        assertScreenSnapshots(of: view)
    }
}
#endif
