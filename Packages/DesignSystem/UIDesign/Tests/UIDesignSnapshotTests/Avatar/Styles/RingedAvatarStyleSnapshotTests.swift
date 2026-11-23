#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct RingedAvatarStyleSnapshotTests {
    /// A made-up person whose initials differ.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// Every size, smallest first.
    private static let sizes: [AvatarSize] = [.small, .medium, .large, .xLarge]

    /// Every palette the ringed style names.
    private static let palettes: [AvatarRingPalette] = [
        .neutral, .blue, .teal, .violet, .raspberry, .sponsor,
    ]

    /// Every surface the design system ships, from the base surface to the tertiary grouped one.
    private static let surfaces: [BrandShapeStyle] = [
        .surface,
        .secondarySurface,
        .tertiarySurface,
        .groupedSurface,
        .secondaryGroupedSurface,
        .tertiaryGroupedSurface,
    ]

    /// Checks every size, with and without a status, because the mark sits over the ring.
    @Test func ringedStyle() {
        let view = VStack(alignment: .leading, spacing: Spacing.lg) {
            row(status: nil)
            row(status: AvatarStatus("Checked in"))
        }
        .avatarStyle(.ringed)
        .avatarRingPalette(.blue)
        .padding(Spacing.lg)

        assertSnapshots(of: view)
    }

    /// Checks every palette on every surface, because the ring has to show against each of them.
    @Test func ringedStyleSurfaces() {
        let view = VStack(spacing: 0) {
            ForEach(Self.surfaces.indices, id: \.self) { index in
                paletteRow().background(Self.surfaces[index])
            }
        }

        assertContrastSnapshots(of: view)
    }

    /// Checks every palette on the elevated dark sheet, which lifts the grouped surface.
    @Test func ringedStyleOnElevatedSheet() {
        let view = paletteRow().background(.tertiaryGroupedSurface)
        let traits = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        // The snapshot helpers have no elevated variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: traits),
            named: "dark-elevated",
        )
    }

    /// Checks the initials under Bold Text, because the letters get heavier inside the ring.
    @Test func ringedStyleBold() {
        let traits = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.legibilityWeight = .bold
        }
        // The snapshot helpers have no Bold variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: ringedRow(status: AvatarStatus("Checked in")).dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: traits),
            named: "light-bold",
        )
    }

    /// Checks the ring under no settings, large text, Increase Contrast and all together.
    @Test func ringedStyleFinalSet() {
        let light = UITraitCollection { $0.userInterfaceStyle = .light }
        let increasedContrast = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.accessibilityContrast = .high
        }
        let everything = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
            $0.legibilityWeight = .bold
        }
        let view = ringedRow(status: AvatarStatus("Checked in"))
        // The snapshot helpers have no combined variant, so this calls assertSnapshot directly.
        assertSnapshot(of: view.dynamicTypeSize(.large).fixedSize(), as: .image(traits: light), named: "none")
        assertSnapshot(
            of: view.dynamicTypeSize(.accessibility5).fixedSize(),
            as: .image(traits: light),
            named: "large-text",
        )
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: increasedContrast),
            named: "increased-contrast",
        )
        assertSnapshot(
            of: view.environment(\.layoutDirection, .rightToLeft).dynamicTypeSize(.accessibility5).fixedSize(),
            as: .image(traits: everything),
            named: "all-together",
        )
    }

    /// Checks that the status moves to the lower leading side, over the ring, in a right-to-left language.
    @Test func ringedStyleRightToLeft() {
        let view = ringedRow(status: AvatarStatus("Checked in"))
            .environment(\.layoutDirection, .rightToLeft)

        assertSnapshots(of: view)
    }

    /// Returns a padded row of every size in the ringed style, with initials.
    ///
    /// - Parameter status: The state to show on each avatar, if any.
    /// - Returns: A row of four blue-ringed avatars, smallest first.
    private func ringedRow(status: AvatarStatus?) -> some View {
        row(status: status)
            .avatarStyle(.ringed)
            .avatarRingPalette(.blue)
            .padding(Spacing.lg)
    }

    /// Returns a padded row with one ringed avatar for each palette.
    ///
    /// - Returns: A row of six avatars with initials.
    private func paletteRow() -> some View {
        HStack(spacing: Spacing.lg) {
            ForEach(Self.palettes.indices, id: \.self) { index in
                Avatar(url: nil, size: .large, fallback: .initials(Self.name))
                    .avatarRingPalette(Self.palettes[index])
            }
        }
        .avatarStyle(.ringed)
        .padding(Spacing.lg)
    }

    /// Returns a row of every size with initials.
    ///
    /// - Parameter status: The state to show on each avatar, if any.
    /// - Returns: A row of four avatars, smallest first.
    private func row(status: AvatarStatus?) -> some View {
        HStack(alignment: .bottom, spacing: Spacing.lg) {
            ForEach(Self.sizes, id: \.self) { size in
                Avatar(url: nil, size: size, status: status, fallback: .initials(Self.name))
            }
        }
    }
}
#endif
