import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct ColorSpecimenSnapshotTests {
    @Test
    func colors() {
        assertSnapshots(of: ColorSpecimen())
    }

    @Test
    func colorsCompact() {
        assertCompactSnapshots(of: ColorSpecimen())
    }
}
