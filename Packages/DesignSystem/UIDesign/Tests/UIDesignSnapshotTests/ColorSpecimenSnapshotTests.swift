#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct ColorSpecimenSnapshotTests {
    @Test
    func colors() {
        assertColorSpecimenSnapshots(of: ColorSpecimen())
    }
}
#endif
