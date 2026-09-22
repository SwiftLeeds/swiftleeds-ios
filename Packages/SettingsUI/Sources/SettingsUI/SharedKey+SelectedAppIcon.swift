import ColorTheme
import Sharing

extension PreferenceName {
    static let selectedAppIcon = PreferenceName("selectedAppIcon")
}

extension SharedKey where Self == AppStorageKey<AppIconOption>.Default {
    /// The icon the person chose; `.generic` until they choose one.
    package static var selectedAppIcon: Self {
        Self[.appStorage(.selectedAppIcon), default: .generic]
    }
}
