import SettingsUI

extension ContactEmail {
    static var fixture: ContactEmail {
        get throws { try ContactEmail("hello@conference.example") }
    }
}
