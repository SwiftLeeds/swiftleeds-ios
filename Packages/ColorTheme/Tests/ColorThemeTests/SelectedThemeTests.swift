import ColorTheme
import Dependencies
import Sharing
import Testing

@Suite struct SelectedThemeTests {
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
