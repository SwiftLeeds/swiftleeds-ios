#if os(iOS)
import SnapshotTesting
import Testing
import UIDesign

@Suite(.snapshots(record: .never))
@MainActor
struct DimensionSpecimenSnapshotTests {
    /// Checks the specimen of the spacing scale against its reference images.
    @Test
    func spacing() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.spacing))
    }

    /// Checks the specimen of the corner radius scale against its reference images.
    @Test
    func cornerRadius() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.cornerRadius))
    }

    /// Checks the specimen of the border width scale against its reference images.
    @Test
    func borderWidth() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.borderWidth))
    }

    /// Checks the specimen of the line width scale against its reference images.
    @Test
    func lineWidth() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.lineWidth))
    }

    /// Checks the specimen of the icon size scale against its reference images.
    @Test
    func iconSize() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.iconSize))
    }

    /// Checks the specimen of the avatar size scale against its reference images.
    @Test
    func avatarSize() {
        assertSpecimenSnapshots(of: DimensionSpecimen(.avatarSize))
    }
}
#endif
