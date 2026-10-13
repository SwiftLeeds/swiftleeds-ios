import Sharing

extension PreferenceKey {
    /// The key the chosen theme is stored under.
    public static let selectedTheme = PreferenceKey("selectedTheme")
}

extension SharedKey where Self == AppStorageKey<ThemeOption>.Default {
    /// The theme the person chose; `.system` until they choose one.
    public static var selectedTheme: Self {
        Self[.appStorage(.selectedTheme), default: .system]
    }
}
