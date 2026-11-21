#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct LogoSnapshotTests {
    /// The side of a logo's frame, as a sponsor row draws it, in points.
    private static let tileSide: CGFloat = 56

    /// The side of the dark sample mark, in points.
    private static let darkMarkSide: CGFloat = 200

    /// The width of the dark sample mark's ring, in points.
    private static let darkMarkRingWidth: CGFloat = 24

    /// The share of the dark sample mark's side that its centre dot spans.
    private static let darkMarkDotShare: CGFloat = 0.3

    /// The lightness of the dark sample mark's ink, from 0 (black) to 1 (white).
    private static let darkInk = Color(white: 0.1)

    /// A made-up round mark in dark ink on a transparent background, with no lettering.
    private static var darkInkMark: Image {
        let size = CGSize(width: darkMarkSide, height: darkMarkSide)
        return Image(size: size) { context in
            let outer = CGRect(origin: .zero, size: size).insetBy(dx: darkMarkRingWidth, dy: darkMarkRingWidth)
            context.stroke(Path(ellipseIn: outer), with: .color(darkInk), lineWidth: darkMarkRingWidth)
            let dotSide = size.width * darkMarkDotShare
            let dot = CGRect(
                x: (size.width - dotSide) / 2,
                y: (size.height - dotSide) / 2,
                width: dotSide,
                height: dotSide,
            )
            context.fill(Path(ellipseIn: dot), with: .color(darkInk))
        }
    }

    /// Draws a loaded mark in a logo's frame, on the base surface.
    ///
    /// - Parameter mark: The image the logo has loaded.
    /// - Returns: The logo with room around it.
    private func loadedLogo(_ mark: Image) -> some View {
        Logo(phase: .success(mark)) { EmptyView() }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(.surface)
    }

    @Test func whenPhaseIsSuccessWithDarkInkMark_shouldDrawMarkInsetOnTile() {
        assertContrastSnapshots(of: loadedLogo(Self.darkInkMark))
    }

    @Test func whenPhaseIsSuccessWithWideMark_shouldDrawMarkInsetOnTile() {
        assertContrastSnapshots(of: loadedLogo(.wideSampleMark))
    }

    @Test func whenPhaseIsSuccessInDarkElevatedSheet_shouldDrawTileOnElevatedSurface() {
        let darkElevated = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        let view = Logo(phase: .success(Self.darkInkMark)) { EmptyView() }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(Color.gray)
        // The snapshot helpers have no elevated variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: darkElevated),
            named: "dark-elevated",
        )
    }
}
#endif
