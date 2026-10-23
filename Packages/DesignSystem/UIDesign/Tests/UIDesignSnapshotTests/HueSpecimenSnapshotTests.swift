#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

/// Snapshot tests for ``HueSpecimen``.
@Suite(.snapshots(record: .never))
@MainActor
struct HueSpecimenSnapshotTests {
    /// Checks the specimen of every hue's ramp against its reference images.
    @Test
    func ramps() {
        assertSpecimenSnapshots(of: HueSpecimen())
    }
}
#endif
