import SettingsUI

extension AppVersion {
    static var fixture: AppVersion {
        get throws { try AppVersion("2.1.0") }
    }
}
