import SettingsUI

extension SettingsViewModel {
    static var fixture: SettingsViewModel {
        get throws {
            SettingsViewModel(contactEmail: try .fixture, appVersion: try .fixture)
        }
    }
}
