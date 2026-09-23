import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct IconSpecimenSnapshotTests {
    @Test
    func icons() {
        assertSnapshots(of: IconSpecimen())
    }

    @Test
    func iconsCompact() {
        assertCompactSnapshots(of: IconSpecimen())
    }
}
