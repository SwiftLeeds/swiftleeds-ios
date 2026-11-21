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

    /// The width of a portrait frame, in points.
    private static let portraitWidth: CGFloat = 100

    /// The height of a portrait frame, in points.
    private static let portraitHeight: CGFloat = 150

    /// The space around a portrait frame, wide enough to show a picture that overflows it.
    private static let overflowRoom: CGFloat = 64

    /// The shape of a hero, as width over height.
    private static let heroRatio: CGFloat = 16.0 / 9.0

    /// A loaded picture in a portrait frame, with room around it to show any overflow.
    private var croppedPicture: some View {
        Photo(phase: .success(.samplePhoto)) { EmptyView() }
            .frame(width: Self.portraitWidth, height: Self.portraitHeight)
            .padding(Self.overflowRoom)
            .background(.surface)
    }

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

    @Test func whenPhaseIsFailureAtLargestTextSize_shouldDrawSameFallback() {
        assertSpecimenSnapshots(
            of: thumbnail(phase: .failure(Self.failure)).dynamicTypeSize(.accessibility5),
            testName: "whenPhaseIsFailure_shouldDrawFallback",
        )
    }

    @Test func whenPhaseIsEmptyInHeroAtCompactWidth_shouldDrawGreyFill() {
        let hero = Photo(phase: .empty) { EmptyView() }
            .aspectRatio(Self.heroRatio, contentMode: .fit)
            .padding(.lg)
            .background(.surface)
        assertCompactSnapshots(of: hero)
    }

    @Test func whenPictureLoadedInPortraitFrame_shouldCropToFrame() {
        assertSpecimenSnapshots(of: croppedPicture)
    }

    @Test func whenPictureLoadedWithEverySettingOn_shouldCropToFrame() {
        let everySetting = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
            $0.legibilityWeight = .bold
            $0.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        }
        assertSnapshot(
            of: croppedPicture.dynamicTypeSize(.accessibility5).fixedSize(),
            as: .image(traits: everySetting),
            named: "every-setting",
        )
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
