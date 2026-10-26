#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

/// Snapshot tests for ``BrandSpecimen``.
@Suite(.snapshots(record: .never))
@MainActor
struct BrandSpecimenSnapshotTests {
    /// Checks the specimen of every brand's roles and surfaces against its reference images.
    @Test
    func brands() {
        assertColorSpecimenSnapshots(of: BrandSpecimen())
    }
}
#endif
