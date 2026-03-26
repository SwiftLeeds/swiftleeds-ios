import ColorTheme
import SwiftUI
import UIKit

final class SettingsViewModel: ObservableObject {
    @Published var currentIcon: AppIconOption = .generic
    @Published var showingIconError = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var contactEmail: String {
        guard let email = Bundle.main.object(forInfoDictionaryKey: "ContactEmail") as? String, !email.isEmpty else {
            assertionFailure("Missing Info.plist key: ContactEmail")
            return ""
        }
        return email
    }

    private var codeOfConductHost: String {
        guard let host = Bundle.main.object(forInfoDictionaryKey: "APIHost") as? String, !host.isEmpty else {
            assertionFailure("Missing Info.plist key: APIHost")
            return ""
        }
        return host
    }

    init() {
        loadCurrentIcon()
    }

    func changeAppIcon(to iconOption: AppIconOption) {
        guard UIApplication.shared.supportsAlternateIcons else {
            showingIconError = true
            return
        }
        
        UIApplication.shared.setAlternateIconName(iconOption.iconName) { [weak self] error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showingIconError = true
                } else {
                    self?.currentIcon = iconOption
                    UserDefaults.standard.set(iconOption.rawValue, forKey: UserDefaultsKeys.selectedAppIcon)
                }
            }
        }
    }
    
    func openContactUs() {
        if let url = URL(string: "mailto:\(contactEmail)") {
            UIApplication.shared.open(url)
        }
    }

    func openCodeOfConduct() {
        if let url = URL(string: "https://\(codeOfConductHost)/conduct") {
            UIApplication.shared.open(url)
        }
    }
    
    private func loadCurrentIcon() {
        if let savedIcon = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedAppIcon),
           let iconOption = AppIconOption(rawValue: savedIcon) {
            currentIcon = iconOption
        }
    }
    
}
