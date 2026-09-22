#if canImport(UIKit)
import Dependencies
import Sharing
import SwiftUI
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Shared(.selectedAppIcon) private var storedIcon
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
        currentIcon = storedIcon
    }

    func changeAppIcon(to iconOption: AppIconOption) async {
        @Dependency(\.changeAppIcon) var changeAppIcon

        do {
            try await changeAppIcon(to: iconOption)
            currentIcon = iconOption
            $storedIcon.withLock { $0 = iconOption }
        } catch {
            showingIconError = true
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
}
#endif
