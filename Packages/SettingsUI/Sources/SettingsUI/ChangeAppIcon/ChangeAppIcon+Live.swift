#if canImport(UIKit)
import Dependencies
import UIKit

extension ChangeAppIcon: DependencyKey {
    package static var liveValue: ChangeAppIcon {
        ChangeAppIcon { @MainActor (icon: AppIconOption) async throws(AppIconChangeError) in
            guard UIApplication.shared.supportsAlternateIcons else { throw .unsupported }
            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                throw .refused
            }
        }
    }
}
#endif
