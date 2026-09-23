import SnapshotTesting
import Testing
import UIDesign

// No platform guard. Each helper carries its own and both share a signature,
// so this suite runs on iOS and on macOS.
@Suite(.snapshots(record: .never))
@MainActor
struct DimensionSpecimenSnapshotTests {
    @Test
    func dimensions() {
        assertSnapshots(of: DimensionSpecimen())
    }

    @Test
    func dimensionsCompact() {
        assertCompactSnapshots(of: DimensionSpecimen())
    }
}
