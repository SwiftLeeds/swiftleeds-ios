#if os(watchOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct PhotoWatchSnapshotTests {
    /// The shape of the photo, as width over height.
    private static let ratio: CGFloat = 16.0 / 9.0

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
        assertSnapshots(of: photo(in: .success(.samplePhoto)))
    }

    @Test func whenPhaseIsSuccessWithIncreasedContrast_shouldDrawPicture() {
        let view = photo(in: .success(.samplePhoto))
            .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }
}
#endif
