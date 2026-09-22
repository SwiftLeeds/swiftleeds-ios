import SettingsUI
import Testing

@Suite struct AppIconOptionTests {
    @Test func whenGenericIconIsSet_shouldReturnNoAlternateIconName() {
        #expect(AppIconOption.generic.iconName == nil)
    }

    @Test(arguments: zip([AppIconOption.space, .olympics], ["AppIcon-Space", "AppIcon-Olympics"]))
    func whenAlternateIconIsSet_shouldReturnItsAlternateIconName(icon: AppIconOption, iconName: String) {
        #expect(icon.iconName == iconName)
    }

    @Test(arguments: zip(
        [AppIconOption.generic, .space, .olympics],
        ["AppIcon", "AppIcon-Space", "AppIcon-Olympics"]
    ))
    func whenIconIsStored_shouldWriteItsRawValue(icon: AppIconOption, storedValue: String) {
        #expect(icon.rawValue == storedValue)
    }
}
