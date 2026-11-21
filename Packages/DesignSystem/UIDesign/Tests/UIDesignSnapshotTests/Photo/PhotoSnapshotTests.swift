#if os(iOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct PhotoSnapshotTests {
    /// A failure to hand to a photo in its failed phase.
    private static let failure = URLError(.badServerResponse)

    /// Frames a photo and clips it as a thumbnail, on the base surface.
    ///
    /// - Parameter photo: The photo to show.
    /// - Returns: The thumbnail.
    private func thumbnail(_ photo: some View) -> some View {
        photo
            .frame(avatarSize: .large)
            .clipShape(RoundedRectangle(cornerRadius: .tile))
            .padding(.lg)
            .background(.surface)
    }

    /// Draws a photo in one phase with an artwork as its fallback, as a thumbnail.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The thumbnail.
    private func thumbnail(phase: AsyncImagePhase) -> some View {
        thumbnail(Photo(phase: phase) { Artwork(icon: Icon(.hammerFill), palette: .teal) })
    }

    @Test func whenPhotoHasNoPicture_shouldDrawGreyFill() {
        assertContrastSnapshots(of: thumbnail(Photo(url: nil)))
    }

    @Test func whenPhotoHasNoPictureInDarkElevatedSheet_shouldDrawGreyFill() {
        let darkElevated = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        // The snapshot helpers have no elevated variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: thumbnail(Photo(url: nil)).dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: darkElevated),
            named: "dark-elevated",
        )
    }

    @Test func whenURLIsNil_shouldDrawFallback() {
        let photo = Photo(url: nil) { Artwork(icon: Icon(.hammerFill), palette: .teal) }
        assertContrastSnapshots(of: thumbnail(photo))
    }

    @Test func whenPhaseIsEmpty_shouldDrawGreyFillWithoutFallback() {
        assertContrastSnapshots(of: thumbnail(phase: .empty))
    }

    @Test func whenPhaseIsFailure_shouldDrawFallback() {
        assertContrastSnapshots(of: thumbnail(phase: .failure(Self.failure)))
    }

    @Test func whenPhotoIsRedactedInFailedPhase_shouldDrawGreyFillWithoutFallback() {
        let photo = Photo(phase: .failure(Self.failure)) { Text("Fallback") }
        assertContrastSnapshots(of: thumbnail(photo).redacted(reason: .placeholder))
    }

    @Test func whenPhotoIsRedactedInLoadedPhase_shouldDrawGreyFillWithoutPicture() {
        let photo = Photo(phase: .success(.samplePhoto)) { Text("Fallback") }
        assertContrastSnapshots(of: thumbnail(photo).redacted(reason: .placeholder))
    }
}
#endif
