import Sharing

extension SharedKey where Self == AppStorageKey<AppIconOption>.Default {
    /// The icon the person chose, stored under `selectedAppIcon`; `.generic` until they choose one.
    package static var selectedAppIcon: Self {
        Self[.appStorage("selectedAppIcon"), default: .generic]
    }
}
