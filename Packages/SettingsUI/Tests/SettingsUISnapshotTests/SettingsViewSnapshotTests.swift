#if os(iOS)
import ColorTheme
import SettingsUI
import Sharing
import SwiftUI
import Testing

@MainActor
@Suite struct SettingsViewSnapshotTests {
    @Test func nothingChosen() throws {
        assertScreenSnapshots(of: try settingsView())
    }

    @Test func spaceIconAndDarkTheme() throws {
        @Shared(.selectedAppIcon) var icon
        @Shared(.selectedTheme) var theme
        $icon.withLock { $0 = .space }
        $theme.withLock { $0 = .dark }

        assertScreenSnapshots(of: try settingsView())
    }

    private func settingsView() throws -> some View {
        SettingsView(
            contactEmail: try ContactEmail("hello@conference.example"),
            appVersion: try AppVersion("2.1.0")
        )
    }
}
#endif
