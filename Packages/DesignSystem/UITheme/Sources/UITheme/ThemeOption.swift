#if canImport(UIKit)
import UIKit
#endif

/// Available theme options for the application
public enum ThemeOption: String, CaseIterable, Equatable, Hashable, Sendable {
    case system
    case light
    case dark

    /// User-friendly display name for the theme option
    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

#if canImport(UIKit)
extension ThemeOption {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}
#endif
