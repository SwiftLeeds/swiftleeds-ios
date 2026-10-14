#if canImport(UIKit)
import Sharing
import SwiftUI
import UIKit

struct ApplySelectedTheme: ViewModifier {
    @Shared(.selectedTheme) private var theme

    func body(content: Content) -> some View {
        content
            .onChange(of: theme, initial: true) {
                apply(theme)
            }
    }

    private func apply(_ theme: ThemeOption) {
        let windowScene = UIApplication.shared.connectedScenes.lazy.compactMap { $0 as? UIWindowScene }.first
        guard let windowScene else { return }
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
}

extension View {
    /// Applies the person's chosen theme to the app's windows, now and whenever they change it.
    public func applyingSelectedTheme() -> some View {
        modifier(ApplySelectedTheme())
    }
}
#endif
