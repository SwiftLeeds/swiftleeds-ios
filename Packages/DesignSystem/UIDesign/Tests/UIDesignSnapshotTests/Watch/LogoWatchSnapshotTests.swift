#if os(watchOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct LogoWatchSnapshotTests {
    /// The side of a logo's frame, in points.
    private static let tileSide: CGFloat = 56

    /// Draws a loaded mark in a logo's frame.
    ///
    /// - Parameter mark: The image the logo has loaded.
    /// - Returns: The logo.
    private func loadedLogo(_ mark: Image) -> some View {
        Logo(phase: .success(mark)) { EmptyView() }
            .frame(width: Self.tileSide, height: Self.tileSide)
    }

    @Test func whenPhaseIsSuccessWithDarkInkMark_shouldDrawMarkInsetOnTile() {
        assertSnapshots(of: loadedLogo(.darkInkSampleMark))
    }

    @Test func whenPhaseIsSuccessWithWideMark_shouldDrawMarkInsetOnTile() {
        assertSnapshots(of: loadedLogo(.wideSampleMark))
    }

    @Test func whenPhaseIsSuccessWithWhiteBackedMark_shouldDrawMarkInsetOnTile() {
        assertSnapshots(of: loadedLogo(.whiteBackedSampleMark))
    }
}
#endif
