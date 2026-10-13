import Dependencies
import DependenciesTestSupport
import Sharing
import Testing
import UITheme

@Suite(.dependencies) struct SelectedThemeTests {
    @Test func whenNoThemeIsStored_shouldReturnSystem() {
        @Shared(.selectedTheme) var theme

        #expect(theme == .system)
    }

    @Test func whenThemeIsSelected_shouldStoreItsRawValueUnderSelectedTheme() {
        @Dependency(\.defaultAppStorage) var store
        @Shared(.selectedTheme) var theme

        $theme.withLock { $0 = .dark }

        #expect(store.string(forKey: "selectedTheme") == "dark")
    }

    @Test func whenThemeWasStoredBeforeThisVersion_shouldReturnIt() {
        @Dependency(\.defaultAppStorage) var store
        store.set("light", forKey: "selectedTheme")

        @Shared(.selectedTheme) var theme

        #expect(theme == .light)
    }
}
