#if os(watchOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct PhotoWatchSnapshotTests {
    /// The shape of the loading photo, as width over height.
    private static let ratio: CGFloat = 16.0 / 9.0

    /// The shape of the portrait photo, as width over height.
    private static let portraitRatio: CGFloat = 2.0 / 3.0

    /// Frames a photo as wide as the screen allows.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The framed photo.
    private func photo(in phase: AsyncImagePhase) -> some View {
        Photo(phase: phase) { EmptyView() }
            .aspectRatio(Self.ratio, contentMode: .fit)
    }

    @Test func whenPhaseIsEmpty_shouldDrawGreyFill() {
        assertSnapshots(of: photo(in: .empty))
    }

    @Test func whenPhaseIsEmptyWithIncreasedContrast_shouldDrawGreyFill() {
        let view = photo(in: .empty)
            .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }

    @Test func whenPhaseIsSuccess_shouldDrawPicture() {
        let view = Photo(phase: .success(.samplePhoto)) { EmptyView() }
            .aspectRatio(Self.portraitRatio, contentMode: .fit)

        assertSnapshots(of: view)
    }
}
#endif
