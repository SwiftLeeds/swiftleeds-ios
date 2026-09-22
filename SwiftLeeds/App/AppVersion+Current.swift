import SettingsUI

extension AppVersion {
    static let current: AppVersion = {
        do {
            return try AppVersion(ConferenceConfig.appVersion)
        } catch {
            fatalError("CFBundleShortVersionString is not a version: \(ConferenceConfig.appVersion)")
        }
    }()
}
