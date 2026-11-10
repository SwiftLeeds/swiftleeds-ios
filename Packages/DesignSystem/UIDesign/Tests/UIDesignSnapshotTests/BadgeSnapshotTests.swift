#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct BadgeSnapshotTests {
    /// A badge style that draws the label in a fixed frame, so a test can tell it from the default.
    private struct FixedFrameBadgeStyle: BadgeStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 120

        /// The height of the frame, in points.
        static let height: CGFloat = 44

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// The width of a narrow column, in points, which makes a long title wrap.
    private static let narrowWidth: CGFloat = 160

    /// A title long enough to wrap in a narrow column.
    private static let longTitle = "Fully booked, join the waiting list"

    /// A short badge on a surface, with room around it.
    private func badge(on surface: some ShapeStyle) -> some View {
        Badge("Workshop")
            .padding(.lg)
            .background(surface)
    }

    /// The six palettes, each with "Workshop", stacked on a surface.
    private func palettes(on surface: some ShapeStyle) -> some View {
        VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop").badgePalette(.neutral)
            Badge("Workshop").badgePalette(.blue)
            Badge("Workshop").badgePalette(.teal)
            Badge("Workshop").badgePalette(.violet)
            Badge("Workshop").badgePalette(.raspberry)
            Badge("Workshop").badgePalette(.sponsor)
        }
        .padding(.lg)
        .background(surface)
    }

    @Test func palettesOnSurface() {
        assertContrastSnapshots(of: palettes(on: .surface))
    }

    @Test func palettesOnSecondarySurface() {
        assertContrastSnapshots(of: palettes(on: .secondarySurface))
    }

    @Test func paletteSetOnParentReachesEveryBadge() {
        let view = HStack {
            Badge("Workshop")
            Badge("Talk")
        }
        .badgePalette(.teal)
        .padding(.lg)
        .background(.surface)
        assertSpecimenSnapshots(of: view)
    }

    @Test func workshopOnSurface() {
        assertContrastSnapshots(of: badge(on: .surface))
    }

    @Test func workshopOnSecondarySurface() {
        assertContrastSnapshots(of: badge(on: .secondarySurface))
    }

    @Test func longTitleWraps() {
        let view = Badge(Self.longTitle)
            .padding(.lg)
            .frame(width: Self.narrowWidth)
            .background(.surface)
        assertContrastSnapshots(of: view)
    }

    @Test func longTitleWithLineLimit() {
        let view = Badge(Self.longTitle)
            .lineLimit(1)
            .padding(.lg)
            .frame(width: Self.narrowWidth)
            .background(.surface)
        assertContrastSnapshots(of: view)
    }

    @Test func styleSetOnParentReachesBadge() {
        let view = VStack { Badge("Workshop") }
            .badgeStyle(FixedFrameBadgeStyle())
            .padding(.lg)
            .background(.surface)
        assertSpecimenSnapshots(of: view)
    }
}
#endif
