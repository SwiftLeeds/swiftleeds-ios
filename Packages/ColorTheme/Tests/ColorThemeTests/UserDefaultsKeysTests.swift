import ColorTheme
import Testing

@Suite struct UserDefaultsKeysTests {
    @Test func whenThemeIsStored_shouldUseSelectedThemeKey() {
        #expect(UserDefaultsKeys.selectedTheme == "selectedTheme")
    }

    @Test func whenAppIconIsStored_shouldUseSelectedAppIconKey() {
        #expect(UserDefaultsKeys.selectedAppIcon == "selectedAppIcon")
    }
}
