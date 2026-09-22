import Sharing

extension SharedKey where Self == AppStorageKey<ThemeOption>.Default {
    /// The theme the person chose, stored under `selectedTheme`; `.system` until they choose one.
    public static var selectedTheme: Self {
        Self[.appStorage("selectedTheme"), default: .system]
    }
}
