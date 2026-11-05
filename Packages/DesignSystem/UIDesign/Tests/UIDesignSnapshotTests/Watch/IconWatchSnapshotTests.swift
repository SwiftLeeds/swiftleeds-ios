#if os(watchOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct IconWatchSnapshotTests {
    @Test func labels() {
        let view = VStack(alignment: .leading) {
            Label("10:30", icon: .clock)
            Label("Main hall", icon: .location)
            Label("Live", icon: .live)
        }

        assertSnapshots(of: view)
    }
}
#endif
