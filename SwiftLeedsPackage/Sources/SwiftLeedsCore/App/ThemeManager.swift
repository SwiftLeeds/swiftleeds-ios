//
//  ThemeManager.swift
//  SwiftLeeds
//
//  Created by Adam Rush on 23/08/2025.
//

import SwiftUI
import UIKit

/// Available theme options for the application
enum ThemeOption: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    /// User-friendly display name for the theme option
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    /// Corresponding UIUserInterfaceStyle for the theme
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

/// Manages the application's theme settings and appearance
final class ThemeManager: ObservableObject {
    /// Shared singleton instance
    static let shared = ThemeManager()
    
    /// Currently selected theme, automatically synced with UserDefaults
    @Published var currentTheme: ThemeOption = .system
    
    private init() {
        loadTheme()
        applyTheme(currentTheme)
    }
    
    /// Updates the application theme and persists the selection
    /// - Parameter theme: The new theme to apply
    func setTheme(_ theme: ThemeOption) {
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
