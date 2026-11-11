#if os(iOS)
import SFSafeSymbols
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

    /// The height of a list that holds two rows, in points.
    private static let listHeight: CGFloat = 220

    /// A title long enough to wrap in a narrow column.
    private static let longTitle = "Fully booked, join the waiting list"

    /// A neutral and a teal badge, each with a hammer icon, on the primary surface.
    private var iconBadges: some View {
        VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop", icon: Icon(.hammerFill))
            Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
        }
        .padding(.lg)
        .background(.surface)
    }

    /// A title-only, an icon and a status badge, stacked on the primary surface.
    private var loadingBadges: some View {
        VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop")
            Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
            Badge("Cancelled", status: .error)
        }
        .padding(.lg)
        .background(.surface)
        .redacted(reason: .placeholder)
    }

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

    /// The four statuses stacked on a surface.
    private func statuses(on surface: some ShapeStyle) -> some View {
        VStack(alignment: .leading, spacing: .md) {
            Badge("Confirmed", status: .success)
            Badge("Few seats", status: .warning)
            Badge("Cancelled", status: .error)
            Badge("New", status: .info)
        }
        .padding(.lg)
        .background(surface)
    }

    @Test func statusesOnSurface() {
        assertContrastSnapshots(of: statuses(on: .surface))
    }

    @Test func statusesOnSecondarySurface() {
        assertContrastSnapshots(of: statuses(on: .secondarySurface))
    }

    @Test func whenStatusSitsInsidePalette_shouldKeepStatusColors() {
        let view = VStack(alignment: .leading, spacing: .md) {
            Badge("Cancelled", status: .error)
            Badge("Workshop")
        }
        .badgePalette(.teal)
        .padding(.lg)
        .background(.surface)
        assertSpecimenSnapshots(of: view)
    }

    @Test func badgesAtLargestTextSize() {
        let view = VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop")
            Badge("Workshop", icon: Icon(.hammerFill))
            Badge("Cancelled", status: .error)
        }
        .padding(.lg)
        .background(.surface)
        .dynamicTypeSize(.accessibility5)
        assertSpecimenSnapshots(of: view, testName: "badgesAtLargestTextSize")
    }

    /// The six palettes and the four statuses in the filled style, stacked on a surface.
    private func filledFamilies(on surface: some ShapeStyle) -> some View {
        VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop").badgePalette(.neutral)
            Badge("Workshop").badgePalette(.blue)
            Badge("Workshop").badgePalette(.teal)
            Badge("Workshop").badgePalette(.violet)
            Badge("Workshop").badgePalette(.raspberry)
            Badge("Workshop").badgePalette(.sponsor)
            Badge("Confirmed", status: .success)
            Badge("Few seats", status: .warning)
            Badge("Cancelled", status: .error)
            Badge("New", status: .info)
        }
        .badgeStyle(.filled)
        .padding(.lg)
        .background(surface)
    }

    @Test func filledOnSurface() {
        assertContrastSnapshots(of: filledFamilies(on: .surface))
    }

    @Test func filledOnSecondarySurface() {
        assertContrastSnapshots(of: filledFamilies(on: .secondarySurface))
    }

    @Test func filledAtLargestTextSize() {
        let view = VStack(alignment: .leading, spacing: .md) {
            Badge("Workshop")
            Badge("Workshop", icon: Icon(.hammerFill))
            Badge("Cancelled", status: .error)
        }
        .badgeStyle(.filled)
        .padding(.lg)
        .background(.surface)
        .dynamicTypeSize(.accessibility5)
        assertSpecimenSnapshots(of: view, testName: "filledAtLargestTextSize")
    }

    @Test func filledInListRow() {
        let view = List {
            HStack {
                Text("Building accessible apps")
                Badge("Live", status: .error)
            }
            HStack {
                Text("Building accessible apps")
                Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
            }
        }
        .badgeStyle(.filled)
        .frame(width: rowWidth, height: Self.listHeight)
        assertSpecimenSnapshots(of: view)
    }

    @Test func loadingTinted() {
        assertSpecimenSnapshots(of: loadingBadges.badgeStyle(.tinted))
    }

    @Test func loadingFilled() {
        assertSpecimenSnapshots(of: loadingBadges.badgeStyle(.filled))
    }

    @Test func iconOnSurface() {
        assertContrastSnapshots(of: iconBadges)
    }

    @Test func iconInListRow() {
        let view = List {
            HStack {
                Text("Building accessible apps")
                Badge("Workshop", icon: Icon(.hammerFill))
            }
            HStack {
                Text("Building accessible apps")
                Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
            }
        }
        .frame(width: rowWidth, height: Self.listHeight)
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenCallerSetsTitleOnlyLabelStyle_shouldKeepSymbol() {
        let view = Badge("Workshop", icon: Icon(.hammerFill))
            .labelStyle(.titleOnly)
            .padding(.lg)
            .background(.surface)
        assertSpecimenSnapshots(of: view)
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
