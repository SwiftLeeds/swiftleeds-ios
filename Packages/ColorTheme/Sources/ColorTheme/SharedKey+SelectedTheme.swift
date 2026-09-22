import Sharing

extension PreferenceName {
    /// The name the chosen theme is stored under.
    public static let selectedTheme = PreferenceName("selectedTheme")
}

extension SharedKey where Self == AppStorageKey<ThemeOption>.Default {
    /// The theme the person chose; `.system` until they choose one.
    public static var selectedTheme: Self {
        Self[.appStorage(.selectedTheme), default: .system]
    }
}
