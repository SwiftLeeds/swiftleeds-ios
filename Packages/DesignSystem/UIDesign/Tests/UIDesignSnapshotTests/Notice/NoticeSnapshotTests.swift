#if os(iOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct NoticeSnapshotTests {
    /// A notice style that draws the title in a fixed frame, so a test can tell it from the default.
    private struct FixedFrameNoticeStyle: NoticeStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 120

        /// The height of the frame, in points.
        static let height: CGFloat = 44

        func makeBody(configuration: Configuration) -> some View {
            configuration.title
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// A notice style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemeNoticeStyle: NoticeStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// The height of a list that holds one notice and room around it, in points.
    private static let listHeight: CGFloat = 260

    /// The height of a list tall enough for a notice at the largest text size, in points.
    private static let tallListHeight: CGFloat = 900

    /// The height of a list tall enough for a notice at the largest text size on a narrow screen, in points.
    private static let compactListHeight: CGFloat = 2_400

    /// A notice with a title, a description and an action, on the primary surface.
    private var notice: some View {
        Notice(
            "You're offline",
            icon: Icon(.wifiSlash),
            description: Text("The schedule shows what was saved. It updates when you reconnect."),
        ) {
            Button("Try Again") {}
                .buttonStyle(.borderless)
        }
        .padding(.lg)
        .background(.surface)
    }

    @Test func whenStyleReadsColorScheme_shouldSeeCurrentScheme() {
        assertSpecimenSnapshots(of: notice.noticeStyle(ColorSchemeNoticeStyle()))
    }

    @Test func whenStyleIsSetOnParent_shouldReachNotice() {
        let view = VStack { notice }
            .noticeStyle(FixedFrameNoticeStyle())
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenNoticeHasAction_shouldDrawActionUnderDescription() {
        let view = List {
            Section {
                Notice(
                    "You're offline",
                    icon: Icon(.wifiSlash),
                    description: Text("The schedule shows what was saved. It updates when you reconnect."),
                ) {
                    Button("Try Again") {}
                        .buttonStyle(.borderless)
                }
            }
        }
        .frame(width: narrowestPhoneWidth, height: Self.listHeight)
        assertContrastSnapshots(of: view)
    }

    @Test func whenTextIsAccessibilitySize_shouldHideIcon() {
        assertSnapshots(of: noticeList.frame(width: narrowestPhoneWidth, height: Self.tallListHeight))
    }

    @Test func whenWidthIsCompact_shouldWrapText() {
        assertCompactSnapshots(of: noticeList.frame(height: Self.compactListHeight))
    }

    @Test func whenTextIsBold_shouldDrawBoldText() {
        let view = noticeList.frame(width: narrowestPhoneWidth, height: Self.listHeight)
        let light = UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.legibilityWeight = .bold
        }
        let dark = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.legibilityWeight = .bold
        }
        // The snapshot helpers cannot set Bold Text, so this calls assertSnapshot directly.
        assertSnapshot(of: view.dynamicTypeSize(.large).fixedSize(), as: .image(traits: light), named: "light-default")
        assertSnapshot(of: view.dynamicTypeSize(.large).fixedSize(), as: .image(traits: dark), named: "dark-default")
    }

    @Test func whenLoading_shouldRedactEveryPart() {
        let list = noticeList.frame(width: narrowestPhoneWidth, height: Self.listHeight)
        assertSpecimenSnapshots(of: list.redacted(reason: .placeholder))
    }

    @Test func whenOnDarkElevatedSheet_shouldKeepText() {
        let view = noticeList.frame(width: narrowestPhoneWidth, height: Self.listHeight)
        let sheet = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.userInterfaceLevel = .elevated
        }
        // The snapshot helpers have no elevated variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: view.dynamicTypeSize(.large).fixedSize(),
            as: .image(traits: sheet),
            named: "dark-elevated",
        )
    }

    @Test func whenEverySettingIsOn_shouldKeepTextReadable() {
        let view = noticeList.frame(width: narrowestPhoneWidth, height: Self.tallListHeight)
        let settings = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
            $0.legibilityWeight = .bold
        }
        assertSnapshot(
            of: view.dynamicTypeSize(.accessibility5).fixedSize(),
            as: .image(traits: settings),
            named: "dark-accessibility-increased-contrast-bold",
        )
    }

    @Test func whenNoticeHasNoActions_shouldLeaveNoGapBelowText() {
        let view = outlined(
            Notice(
                title: { Text("You're offline") },
                icon: { Image(icon: Icon(.wifiSlash)) },
                description: { Text("The schedule shows what was saved. It updates when you reconnect.") },
            )
        )
        assertSpecimenSnapshots(of: view)
    }

    @Test func whenNoticeHasAction_shouldLeaveGapBelowText() {
        let view = outlined(
            Notice(
                title: { Text("You're offline") },
                icon: { Image(icon: Icon(.wifiSlash)) },
                description: { Text("The schedule shows what was saved. It updates when you reconnect.") },
                actions: { Button("Try Again") {}.buttonStyle(.borderless) },
            )
        )
        assertSpecimenSnapshots(of: view)
    }
}

extension NoticeSnapshotTests {
    /// The documented call site: a notice with a borderless action in a list section.
    private var noticeList: some View {
        List {
            Section {
                Notice(
                    "You're offline",
                    icon: Icon(.wifiSlash),
                    description: Text("The schedule shows what was saved. It updates when you reconnect."),
                ) {
                    Button("Try Again") {}
                        .buttonStyle(.borderless)
                }
            }
        }
    }

    /// The width of the outline, in points.
    private static let outlineWidth: CGFloat = 1

    /// Returns a notice at a row's width with its bounds outlined, so a gap inside it shows.
    ///
    /// The outline sits just outside the notice, so it cannot hide anything that overflows.
    ///
    /// - Parameter notice: The notice to outline.
    /// - Returns: The notice, outlined, on the primary surface.
    private func outlined(_ notice: some View) -> some View {
        notice
            .frame(width: rowWidth)
            .padding(Self.outlineWidth)
            .border(Color.primary, width: Self.outlineWidth)
            .padding(.lg)
            .background(.surface)
    }
}
#endif
