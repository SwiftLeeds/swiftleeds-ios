#if os(iOS)
import Foundation
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarGroupSnapshotTests {
    /// A group style that draws the content in a fixed frame, so a test can tell it from the default.
    private struct FixedFrameAvatarGroupStyle: AvatarGroupStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 160

        /// The height of the frame, in points.
        static let height: CGFloat = 60

        func makeBody(configuration: Configuration) -> some View {
            HStack { configuration.content }
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// A group style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemeAvatarGroupStyle: AvatarGroupStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// A group beside the names it stands for, stacking above them at accessibility text sizes, as the
    /// group's documentation shows.
    private struct SessionRow: View {
        /// The current Dynamic Type size.
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        var body: some View {
            let layout =
                dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading))
                : AnyLayout(HStackLayout())
            layout {
                AvatarGroup {
                    ForEach(AvatarGroupSnapshotTests.people.prefix(5), id: \.self) { name in
                        Avatar(url: nil, size: .small, fallback: .initials(name))
                    }
                }
                Text("Ada Archer, Blake Brooks and 3 more")
            }
        }
    }

    /// The height of a list that holds one row at the default text size, in points.
    private static let defaultRowListHeight: CGFloat = 100

    /// The height of a list that holds one stacked row at the largest text size, in points.
    private static let largestRowListHeight: CGFloat = 420

    /// The height of a list that holds four rows of groups, in points.
    private static let groupListHeight: CGFloat = 300

    /// Every surface the design system ships, from the base surface to the tertiary grouped one.
    private static let surfaces: [BrandShapeStyle] = [
        .surface,
        .secondarySurface,
        .tertiarySurface,
        .groupedSurface,
        .secondaryGroupedSurface,
        .tertiaryGroupedSurface,
    ]

    /// Six made-up people whose initials differ, so the image can tell them apart.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

    /// Three avatars with initials, the group the style tests draw in their own style.
    private static var threeAvatars: some View {
        AvatarGroup {
            ForEach(people.prefix(3), id: \.self) { name in
                Avatar(url: nil, size: .small, fallback: .initials(name))
            }
        }
    }

    @Test func whenThreeAvatars_shouldDrawSideBySide() {
        let view = AvatarGroup {
            ForEach(Self.people.prefix(3), id: \.self) { name in
                Avatar(url: nil, size: .small, fallback: .initials(name))
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenOneOrTwoAvatars_shouldDrawEach() {
        let view = VStack(alignment: .leading, spacing: Spacing.lg) {
            AvatarGroup {
                Avatar(url: nil, size: .small, fallback: .initials(Self.people[0]))
            }

            AvatarGroup {
                ForEach(Self.people.prefix(2), id: \.self) { name in
                    Avatar(url: nil, size: .small, fallback: .initials(name))
                }
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenAvatarsHaveStatuses_shouldShowEachMark() {
        let view = AvatarGroup {
            Avatar(
                url: nil,
                size: .small,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.people[0]),
            )

            Avatar(
                url: nil,
                size: .small,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    family: .warning,
                ),
                fallback: .initials(Self.people[1]),
            )

            Avatar(url: nil, size: .small, fallback: .initials(Self.people[2]))
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenStyleReadsColorScheme_shouldSeeTheCurrentScheme() {
        let view = Self.threeAvatars
            .avatarGroupStyle(ColorSchemeAvatarGroupStyle())
            .padding(.lg)
            .background(.surface)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenStyleIsSetOnParent_shouldReachGroup() {
        let view = VStack { Self.threeAvatars }
            .avatarGroupStyle(FixedFrameAvatarGroupStyle())
            .padding(.lg)
            .background(.surface)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenFourAvatars_shouldShowTwoAndCountOfTwo() {
        assertSnapshots(of: Self.group(of: 4))
    }

    @Test func whenFourteenAvatars_shouldShowCountOfTwelve() {
        assertSnapshots(of: Self.group(of: 14))
    }

    @Test func whenFourLargeAvatars_shouldDrawCountAtLargeSize() {
        let view = AvatarGroup {
            ForEach(Self.people.prefix(4), id: \.self) { name in
                Avatar(url: nil, size: .large, fallback: .initials(name))
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenHundredAndOneAvatars_shouldShowCountOfNinetyNine() {
        assertSnapshots(of: Self.group(of: 101))
    }

    @Test func whenHundredAndTwoAvatars_shouldShowNinetyNinePlus() {
        assertSnapshots(of: Self.group(of: 102))
    }

    @Test func whenNoMemberIsAvatar_shouldShowEveryMemberAndNoCount() {
        let view = AvatarGroup {
            ForEach(0..<5, id: \.self) { _ in
                Circle().fill(.secondarySurface).frame(width: 28, height: 28)
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }
}

extension AvatarGroupSnapshotTests {
    @Test func whenLoading_shouldDrawPlainShapes() {
        let view = Self.statusGroup(count: 5)
            .redacted(reason: .placeholder)
            .padding(.lg)
            .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenOnEverySurface_shouldDrawEveryMark() {
        let view = VStack(spacing: 0) {
            ForEach(Self.surfaces.indices, id: \.self) { index in
                Self.statusGroup(count: 5)
                    .padding(Spacing.lg)
                    .background(Self.surfaces[index])
            }
        }

        assertContrastSnapshots(of: view)
    }

    @Test func whenOnElevatedDarkSurface_shouldDrawEveryMark() {
        let view = Self.statusGroup(count: 5)
            .padding(.lg)
            .background(.surface)
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

    @Test func whenTextIsBold_shouldDrawCountAsInitials() {
        let view = Self.group(of: 4)
        let traits = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.legibilityWeight = .bold
        }
        // The snapshot helpers have no Bold variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: traits),
            named: "light-default",
        )
    }

    @Test func whenInListRow_shouldKeepRowLayout() {
        let view = List {
            ForEach([1, 2, 3, 4], id: \.self) { count in
                HStack(spacing: Spacing.sm) {
                    Self.statusGroup(count: count)
                    Text("Ada Archer, Blake Brooks")
                }
            }
        }
        .frame(width: narrowestPhoneWidth, height: Self.groupListHeight)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenRowIsAtLargestTextSize_shouldStackGroupAboveNames() {
        let view = List { SessionRow() }
            .dynamicTypeSize(.accessibility5)
            .frame(width: narrowestPhoneWidth, height: Self.largestRowListHeight)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenRowIsAtDefaultTextSize_shouldKeepGroupBesideNames() {
        let view = List { SessionRow() }
            .frame(width: narrowestPhoneWidth, height: Self.defaultRowListHeight)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenRightToLeft_shouldMirrorOrder() {
        let view = Self.statusGroup(count: 5)
            .padding(.lg)
            .background(.surface)
            .environment(\.layoutDirection, .rightToLeft)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenStyleIsRounded_shouldDrawRoundedCount() {
        let view = Self.statusGroup(count: 5)
            .avatarStyle(.rounded)
            .padding(.lg)
            .background(.surface)

        assertContrastSnapshots(of: view)
    }

    @Test func whenEverySettingIsOn_shouldStayReadable() {
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
        let view = Self.statusGroup(count: 5)
            .padding(.lg)
            .background(.surface)
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

    /// Returns a group of small avatars with initials, the first two with a status.
    ///
    /// - Parameter count: How many people the group holds.
    /// - Returns: A group that shows two avatars and a count when `count` is above three.
    private static func statusGroup(count: Int) -> some View {
        AvatarGroup {
            ForEach(0..<count, id: \.self) { index in
                Avatar(
                    url: nil,
                    size: .small,
                    status: index == 0
                        ? AvatarStatus("Checked in")
                        : index == 1
                            ? AvatarStatus("Waitlisted", icon: Icon(.exclamationmarkCircleFill), family: .warning)
                            : nil,
                    fallback: .initials(people[index % people.count]),
                )
            }
        }
    }

    /// Returns a group of small avatars with initials, on the primary surface.
    ///
    /// - Parameter count: How many people the group holds. The names repeat after six.
    /// - Returns: A padded group.
    private static func group(of count: Int) -> some View {
        AvatarGroup {
            ForEach(0..<count, id: \.self) { index in
                Avatar(url: nil, size: .small, fallback: .initials(people[index % people.count]))
            }
        }
        .padding(.lg)
        .background(.surface)
    }
}
#endif
