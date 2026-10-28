#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

/// Snapshot tests for ``OpacitySpecimen``.
@Suite(.snapshots(record: .never))
@MainActor
struct OpacitySpecimenSnapshotTests {
    /// Checks the specimen of the opacity levels against its reference images.
    @Test
    func opacities() {
        assertSpecimenSnapshots(of: OpacitySpecimen())
    }
}
#endif
