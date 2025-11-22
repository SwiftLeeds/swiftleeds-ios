import SwiftUI
import UIKit

final class SettingsViewModel: ObservableObject {
    @Published var currentIcon: AppIconOption = .generic
    @Published var showingIconError = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
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
        if let url = URL(string: "mailto:info@swiftleeds.co.uk") {
            UIApplication.shared.open(url)
        }
    }
    
    func openCodeOfConduct() {
        if let url = URL(string: "https://swiftleeds.co.uk/conduct") {
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
