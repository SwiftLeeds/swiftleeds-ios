import ColorTheme
import Testing

@Suite struct ThemeOptionTests {
    @Test(arguments: zip([ThemeOption.system, .light, .dark], ["system", "light", "dark"]))
    func whenThemeIsStored_shouldWriteItsRawValue(theme: ThemeOption, storedValue: String) {
        #expect(theme.rawValue == storedValue)
    }
}
