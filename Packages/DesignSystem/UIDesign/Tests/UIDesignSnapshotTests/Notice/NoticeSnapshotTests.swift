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

    @Test func whenStyleReadsColorScheme_shouldSeeTheCurrentScheme() {
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
}
#endif
