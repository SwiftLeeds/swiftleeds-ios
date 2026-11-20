#if os(iOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct NoticeSnapshotTests {
    /// The height of a list that holds one notice and room around it, in points.
    private static let listHeight: CGFloat = 260

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
