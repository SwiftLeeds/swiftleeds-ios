import Foundation
import SettingsUI
import Testing

@Suite struct ContactEmailTests {
    @Test func whenAddressHasLocalPartAndDomain_shouldReturnMailtoURL() throws {
        let sut = try ContactEmail("hello@conference.example")

        #expect(sut.mailtoURL == URL(string: "mailto:hello@conference.example"))
    }

    @Test(arguments: ["", "hello", "@conference.example", "hello@", "hello@conference", "a@b@conference.example"])
    func whenAddressIsMalformed_shouldThrowNotAnAddress(text: String) {
        #expect(throws: ContactEmail.ParsingError.notAnAddress(text)) {
            try ContactEmail(text)
        }
    }
}
