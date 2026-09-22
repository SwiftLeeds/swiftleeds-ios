#if canImport(UIKit)
import SwiftUI
import UIKit

/// Manages the application's theme settings and appearance
public final class ThemeManager: ObservableObject {
    /// Shared singleton instance
    public static let shared = ThemeManager()

    /// Currently selected theme, automatically synced with UserDefaults
    @Published public var currentTheme: ThemeOption = .system

    private init() {
        loadTheme()
        applyTheme(currentTheme)
    }

    /// Updates the application theme and persists the selection
    /// - Parameter theme: The new theme to apply
    public func setTheme(_ theme: ThemeOption) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: UserDefaultsKeys.selectedTheme)
        applyTheme(theme)
    }

    /// Loads the saved theme preference from UserDefaults
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedTheme),
           let theme = ThemeOption(rawValue: savedTheme) {
            currentTheme = theme
        }
    }

    /// Applies the specified theme to the application UI
    /// - Parameter theme: The theme to apply
    private func applyTheme(_ theme: ThemeOption) {
        DispatchQueue.main.async {
            self.updateUserInterfaceStyle(theme.userInterfaceStyle)
        }
    }

    /// Updates the user interface style for all windows in the current scene
    /// - Parameter style: The UIUserInterfaceStyle to apply
    private func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            print("Warning: Unable to find window scene for theme application")
            return
        }

        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = style
        }
    }
}
#endif
