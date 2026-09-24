#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct IconSpecimenSnapshotTests {
    @Test
    func icons() {
        assertSpecimenSnapshots(of: IconSpecimen())
    }
}
#endif
