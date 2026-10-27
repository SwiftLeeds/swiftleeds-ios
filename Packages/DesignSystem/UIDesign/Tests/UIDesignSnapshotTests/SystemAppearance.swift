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
    /// Dark mode in an elevated container, such as a sheet.
    case darkElevated
    /// Dark mode with Increase Contrast in an elevated container.
    case darkIncreasedContrastElevated

    /// The name that failure messages use.
    var name: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        case .lightIncreasedContrast: "light with Increase Contrast"
        case .darkIncreasedContrast: "dark with Increase Contrast"
        case .darkElevated: "dark elevated"
        case .darkIncreasedContrastElevated: "dark elevated with Increase Contrast"
        }
    }

    /// The same appearance without Increase Contrast, or `nil` when it has none on.
    var withoutIncreasedContrast: Self? {
        switch self {
        case .light: nil
        case .dark: nil
        case .darkElevated: nil
        case .lightIncreasedContrast: .light
        case .darkIncreasedContrast: .dark
        case .darkIncreasedContrastElevated: .darkElevated
        }
    }

    /// Whether this appearance is light mode.
    var isLight: Bool { self == .light || self == .lightIncreasedContrast }

    /// Whether this appearance is in an elevated container.
    private var isElevated: Bool { self == .darkElevated || self == .darkIncreasedContrastElevated }

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
