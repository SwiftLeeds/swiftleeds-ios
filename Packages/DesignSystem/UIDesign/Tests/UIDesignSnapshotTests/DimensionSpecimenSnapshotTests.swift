#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct DimensionSpecimenSnapshotTests {
    @Test
    func dimensions() {
        assertSpecimenSnapshots(of: DimensionSpecimen())
    }
}
#endif
