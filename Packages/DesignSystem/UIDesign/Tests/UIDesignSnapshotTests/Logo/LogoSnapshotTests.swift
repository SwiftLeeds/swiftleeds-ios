#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct LogoSnapshotTests {
    /// A load failure with no detail, for a phase that is a failure.
    private struct SampleLoadError: Error {}

    /// A style that draws the logo's content and nothing else.
    private struct ContentOnlyLogoStyle: LogoStyle {
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            configuration.content
        }
    }

    /// A row of logos, each framed as a screen frames one: the frame scales with the text size.
    private struct ScaledLogoRow: View {
        /// The side of a logo's frame, in points at the default text size.
        @ScaledMetric(relativeTo: .body) private var side = LogoSnapshotTests.tileSide

        var body: some View {
            HStack(spacing: .lg) {
                tile(Logo(phase: .success(.darkInkSampleMark)) { EmptyView() })
                tile(Logo(phase: .success(.wideSampleMark)) { EmptyView() })
                tile(Logo(phase: .success(.whiteBackedSampleMark)) { EmptyView() })
                tile(Logo(phase: .failure(SampleLoadError())) { Text("EX") })
            }
        }

        /// Frames a logo at the scaled side, on the base surface.
        ///
        /// - Parameter logo: The logo to frame.
        /// - Returns: The logo with room around it.
        private func tile(_ logo: some View) -> some View {
            logo
                .frame(width: side, height: side)
                .padding(.lg)
                .background(.surface)
        }
    }

    /// The side of a logo's frame, as a sponsor row draws it, in points.
    private static let tileSide: CGFloat = 56

    /// Draws a loaded mark in a logo's frame, on the base surface.
    ///
    /// - Parameter mark: The image the logo has loaded.
    /// - Returns: The logo with room around it.
    private func loadedLogo(_ mark: Image) -> some View {
        loadedLogo(mark, on: BrandShapeStyle.surface)
    }

    /// Draws a logo with a text fallback in a logo's frame, on the base surface.
    ///
    /// - Parameter phase: The phase of loading to draw.
    /// - Returns: The logo with room around it.
    private func logoWithTextFallback(in phase: AsyncImagePhase) -> some View {
        Logo(phase: phase) { Text("EX") }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(.surface)
    }

    /// Draws a loaded mark in a logo's frame, on a background.
    ///
    /// - Parameters:
    ///   - mark: The image the logo has loaded.
    ///   - background: The style the logo's surroundings are drawn in.
    /// - Returns: The logo with room around it.
    private func loadedLogo(_ mark: Image, on background: some ShapeStyle) -> some View {
        Logo(phase: .success(mark)) { EmptyView() }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(background)
    }

    @Test func whenLoadedLogoIsAtLargestTextSize_shouldMatchDefaultReferences() {
        assertSpecimenSnapshots(
            of: loadedLogo(.darkInkSampleMark).dynamicTypeSize(.accessibility5),
            testName: "whenPhaseIsSuccessWithDarkInkMark_shouldDrawMarkInsetOnTile",
        )
    }

    @Test func whenEverySettingIsOn_shouldDrawTilesAndMarks() {
        // This image is for a person to judge. Its Bold key only proves that the image renders
        // with Bold on, so it is not a guard against a regression.
        let allSettings = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
            $0.legibilityWeight = .bold
        }
        let view = ScaledLogoRow().dynamicTypeSize(.accessibility5)
        // The snapshot helpers have no Bold variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: view.fixedSize(),
            as: .image(traits: allSettings),
            named: "dark-increased-contrast-accessibility5-bold",
        )
    }

    @Test func whenFailedLogoIsRedacted_shouldDrawGrayTileWithoutFallback() {
        let view = logoWithTextFallback(in: .failure(SampleLoadError()))
            .redacted(reason: .placeholder)
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenLoadedLogoIsRedacted_shouldDrawGrayTileWithoutMark() {
        let view = loadedLogo(.darkInkSampleMark)
            .redacted(reason: .placeholder)
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenRedactedLogoHasCustomStyle_shouldDrawGrayFill() {
        let view = logoWithTextFallback(in: .failure(SampleLoadError()))
            .logoStyle(ContentOnlyLogoStyle())
            .redacted(reason: .placeholder)
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenURLIsNilWithTextFallback_shouldDrawTextOnTile() {
        let view = Logo(url: nil) { Text("EX") }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(.surface)
        assertContrastSnapshots(of: view)
    }

    @Test func whenPhaseIsEmptyWithTextFallback_shouldDrawEmptyTile() {
        assertContrastSnapshots(of: logoWithTextFallback(in: .empty))
    }

    @Test func whenPhaseIsFailureWithTextFallback_shouldDrawTextOnTile() {
        assertContrastSnapshots(of: logoWithTextFallback(in: .failure(SampleLoadError())))
    }

    @Test func whenPhaseIsSuccessWithDarkInkMark_shouldDrawMarkInsetOnTile() {
        assertContrastSnapshots(of: loadedLogo(.darkInkSampleMark))
    }

    @Test func whenPhaseIsSuccessWithWideMark_shouldDrawMarkInsetOnTile() {
        assertContrastSnapshots(of: loadedLogo(.wideSampleMark))
    }

    @Test func whenPhaseIsSuccessWithWhiteBackedMark_shouldDrawMarkInsetOnTile() {
        assertContrastSnapshots(of: loadedLogo(.whiteBackedSampleMark))
    }

    @Test func whenTileSitsOnGroupedSurface_shouldDrawEdgeAroundTile() {
        let view = Logo(phase: .empty) { EmptyView() }
            .frame(width: Self.tileSide, height: Self.tileSide)
            .padding(.lg)
            .background(.groupedSurface)
        let light = UITraitCollection { $0.userInterfaceStyle = .light }
        // Light only: in dark mode the grouped surface and the surface are both black, so a dark
        // image would match the empty-phase image. This calls assertSnapshot directly.
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: light),
            named: "light-default",
        )
    }

    @Test func whenPhaseIsSuccessOnGrayPageInDarkElevatedSheet_shouldDrawMarkOnTile() {
        assertDarkElevatedSnapshot(of: loadedLogo(.darkInkSampleMark, on: Color.gray))
    }

    @Test func whenPhaseIsSuccessOnGroupedSurfaceInDarkElevatedSheet_shouldDrawMarkOnTile() {
        assertDarkElevatedSnapshot(of: loadedLogo(.darkInkSampleMark, on: .groupedSurface))
    }

    /// Compares a view with its reference image in a dark, elevated sheet.
    ///
    /// The snapshot helpers have no elevated variant, so this calls `assertSnapshot` directly.
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - testName: The name of the test, which names the reference image.
    private func assertDarkElevatedSnapshot(of view: some View, testName: String = #function) {
        let darkElevated = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: darkElevated),
            named: "dark-elevated",
            testName: testName,
        )
    }
}
#endif
