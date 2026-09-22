import ColorTheme
import Testing

@Suite struct UserDefaultsKeysTests {
    @Test func whenAppIconIsStored_shouldUseSelectedAppIconKey() {
        #expect(UserDefaultsKeys.selectedAppIcon == "selectedAppIcon")
    }
}
