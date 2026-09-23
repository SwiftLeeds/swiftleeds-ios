#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

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
#endif
