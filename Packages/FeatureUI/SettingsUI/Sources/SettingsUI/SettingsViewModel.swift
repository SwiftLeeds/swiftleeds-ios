import Dependencies
import Foundation
import NetworkKit
import Observation
import Sharing

/// The Settings screen's state: the app icon, and the version and links it shows.
@Observable
@MainActor
package final class SettingsViewModel {
    @ObservationIgnored
    @Shared(.selectedAppIcon) private var storedIcon

    /// Whether the last icon change failed.
    package var showingIconError = false

    package let appVersion: AppVersion
    private let contactEmail: ContactEmail

    package init(contactEmail: ContactEmail, appVersion: AppVersion) {
        self.contactEmail = contactEmail
        self.appVersion = appVersion
    }

    package var currentIcon: AppIconOption {
        storedIcon
    }

    /// Changes the app icon, and stores the choice. On failure, keeps the icon and sets
    /// `showingIconError`.
    package func changeAppIcon(to iconOption: AppIconOption) async {
        @Dependency(\.changeAppIcon) var changeAppIcon

        do {
            try await changeAppIcon(to: iconOption)
            $storedIcon.withLock { $0 = iconOption }
        } catch {
            showingIconError = true
        }
    }

    package func openContactUs() async {
        @Dependency(\.openURL) var openURL
        await openURL(contactEmail.mailtoURL)
    }

    package func openCodeOfConduct() async {
        @Dependency(\.apiConfiguration) var apiConfiguration
        @Dependency(\.openURL) var openURL
        if let url = URL(string: "/conduct", relativeTo: apiConfiguration.baseURL)?.absoluteURL {
            await openURL(url)
        }
    }
}
