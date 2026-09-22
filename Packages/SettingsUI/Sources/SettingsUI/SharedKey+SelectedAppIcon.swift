import ColorTheme
import Sharing

extension PreferenceKey {
    static let selectedAppIcon = PreferenceKey("selectedAppIcon")
}

extension SharedKey where Self == AppStorageKey<AppIconOption>.Default {
    /// The icon the person chose; `.generic` until they choose one.
    package static var selectedAppIcon: Self {
        Self[.appStorage(.selectedAppIcon), default: .generic]
    }
}
