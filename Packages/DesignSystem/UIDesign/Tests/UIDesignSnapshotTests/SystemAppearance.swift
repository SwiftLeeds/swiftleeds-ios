#if os(iOS)
import UIKit

/// One way the system can draw a color, with the traits that produce it.
enum SystemAppearance: CaseIterable {
    /// Light mode.
    case light
    /// Dark mode.
    case dark
    /// Light mode with Increase Contrast.
    case lightIncreasedContrast
    /// Dark mode with Increase Contrast.
    case darkIncreasedContrast
    /// Light mode in an elevated container, such as a sheet.
    case lightElevated
    /// Dark mode in an elevated container, such as a sheet.
    case darkElevated
    /// Light mode with Increase Contrast in an elevated container.
    case lightIncreasedContrastElevated
    /// Dark mode with Increase Contrast in an elevated container.
    case darkIncreasedContrastElevated

    /// The name that failure messages use.
    var name: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        case .lightIncreasedContrast: "light with Increase Contrast"
        case .darkIncreasedContrast: "dark with Increase Contrast"
        case .lightElevated: "light elevated"
        case .darkElevated: "dark elevated"
        case .lightIncreasedContrastElevated: "light elevated with Increase Contrast"
        case .darkIncreasedContrastElevated: "dark elevated with Increase Contrast"
        }
    }

    /// The same appearance without Increase Contrast, or `nil` when it has none on.
    var withoutIncreasedContrast: Self? {
        switch self {
        case .light: nil
        case .dark: nil
        case .lightElevated: nil
        case .darkElevated: nil
        case .lightIncreasedContrast: .light
        case .darkIncreasedContrast: .dark
        case .lightIncreasedContrastElevated: .lightElevated
        case .darkIncreasedContrastElevated: .darkElevated
        }
    }

    /// Whether this appearance is light mode.
    var isLight: Bool {
        switch self {
        case .light: true
        case .lightIncreasedContrast: true
        case .lightElevated: true
        case .lightIncreasedContrastElevated: true
        case .dark: false
        case .darkIncreasedContrast: false
        case .darkElevated: false
        case .darkIncreasedContrastElevated: false
        }
    }

    /// Whether this appearance is in an elevated container.
    var isElevated: Bool {
        switch self {
        case .lightElevated: true
        case .darkElevated: true
        case .lightIncreasedContrastElevated: true
        case .darkIncreasedContrastElevated: true
        case .light: false
        case .dark: false
        case .lightIncreasedContrast: false
        case .darkIncreasedContrast: false
        }
    }

    /// The traits the system sets for this appearance.
    @MainActor
    var traits: UITraitCollection {
        UITraitCollection { traits in
            traits.userInterfaceStyle = isLight ? .light : .dark
            traits.accessibilityContrast = withoutIncreasedContrast == nil ? .normal : .high
            traits.userInterfaceLevel = isElevated ? .elevated : .base
        }
    }
}
#endif
