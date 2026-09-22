import SettingsUI

extension ContactEmail {
    static let conference: ContactEmail = {
        do {
            return try ContactEmail(ConferenceConfig.contactEmail)
        } catch {
            fatalError("ContactEmail in Info.plist is not an email address: \(ConferenceConfig.contactEmail)")
        }
    }()
}
