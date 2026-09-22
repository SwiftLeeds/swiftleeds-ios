import SettingsUI
import Testing

@Suite struct AppVersionTests {
    @Test(arguments: ["2", "2.1", "2.1.0", "10.20.30"])
    func whenTextIsOneToThreeNumbers_shouldReturnVersion(text: String) throws {
        let sut = try AppVersion(text)

        #expect(String(sut) == text)
    }

    @Test(arguments: ["", "2.", ".1", "2..1", "2.1.0.4", "v2", "2.x", "-1"])
    func whenTextIsNotAVersion_shouldThrowNotAVersion(text: String) {
        #expect(throws: AppVersion.ParsingError.notAVersion(text)) {
            try AppVersion(text)
        }
    }
}
