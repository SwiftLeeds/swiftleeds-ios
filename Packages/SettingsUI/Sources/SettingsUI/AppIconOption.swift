#if canImport(UIKit)
import UIKit
#endif

package enum AppIconOption: String, CaseIterable {
    case generic = "AppIcon"
    case space = "AppIcon-Space"
    case olympics = "AppIcon-Olympics"

    var displayName: String {
        switch self {
        case .generic: return "General"
        case .space: return "Space"
        case .olympics: return "Sports"
        }
    }

    package var iconName: String? {
        return self == .generic ? nil : rawValue
    }
}

#if canImport(UIKit)
extension AppIconOption {
    var iconImage: UIImage? {
        switch self {
        case .generic:
            return UIImage(named: "AppIconPreview-2024")
        case .space:
            return UIImage(named: "AppIconPreview-Space")
        case .olympics:
            return UIImage(named: "AppIconPreview-Olympics")
        }
    }
}
#endif
