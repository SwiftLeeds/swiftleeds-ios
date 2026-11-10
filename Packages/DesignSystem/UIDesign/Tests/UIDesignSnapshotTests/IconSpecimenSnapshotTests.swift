#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct IconSpecimenSnapshotTests {
    @Test
    func icons() {
        assertSpecimenSnapshots(of: IconSpecimen())
    }

    @Test
    func iconsRightToLeft() {
        assertSpecimenSnapshots(of: IconSpecimen().environment(\.layoutDirection, .rightToLeft))
    }
}
#endif
