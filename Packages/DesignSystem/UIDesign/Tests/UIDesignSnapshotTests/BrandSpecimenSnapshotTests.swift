#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

/// Snapshot tests for ``BrandSpecimen``, and for a component drawn in the other brand.
@Suite(.snapshots(record: .never))
@MainActor
struct BrandSpecimenSnapshotTests {
    /// Checks the specimen of every brand's roles and surfaces against its reference images.
    @Test
    func brands() {
        assertColorSpecimenSnapshots(of: BrandSpecimen())
    }

    /// Checks that a component draws the KotlinLeeds surfaces when the environment sets that brand.
    @Test
    func kotlinLeedsNameplate() {
        let view = Nameplate("Ada Archer", detail: "Northern Software") {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                fallback: .initials(PersonNameComponents(givenName: "Ada", familyName: "Archer")),
            )
        }
        .frame(width: rowWidth)
        .background(.surface)
        .environment(\.brand, .kotlinLeeds)

        assertSpecimenSnapshots(of: view)
    }
}
#endif
