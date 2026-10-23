#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct HueSpecimenSnapshotTests {
    @Test
    func ramps() {
        assertSpecimenSnapshots(of: HueSpecimen())
    }
}
#endif
