import AuthenticationFeature
import ColorTheme
import Dependencies
import Foundation
import LogKit
import LogKitUnified
import NetworkKit
import SecureStorageKit
import SecureStorageKitKeychain
import SwiftUI

@main
struct SwiftLeedsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        prepareDependencies {
            // A fresh salt each launch, so hashed values correlate within a session but never
            // between them. Without a bundle identifier there is no honest subsystem — this
            // ships as two apps — so nothing is written rather than guessing at one.
            $0.log = Bundle.main.bundleIdentifier
                .map { Log.unified(subsystem: LogSubsystem($0), salt: .random()) }
                ?? .none
            $0.secureStorage = .keychain(service: KeychainService("uk.co.swiftleeds.authentication"))
            $0.apiConfiguration = APIConfiguration(baseURL: URL(string: "https://\(ConferenceConfig.apiHost)")!)
            $0.httpClient = .live(onSessionExpiry: {
                @Dependency(\.signOut) var signOut
                try? await signOut()
            })
            $0.signIn = SignIn.liveValue.logging()
            $0.signOut = SignOut.liveValue.logging()
            $0.fetchProfile = FetchProfile.liveValue.logging()
        }
    }

    var body: some Scene {
        WindowGroup {
            Tabs()
                .environmentObject(appState)
                .environmentObject(themeManager)
        }
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        URLCache.shared.diskCapacity = 100_000_000

        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")

        requestPushAuthorization(application: application)

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        @Dependency(\.log) var log
        guard let url = URL(string: ConferenceConfig.pushURL) else {
            log.error("The push URL is not a valid URL: \(ConferenceConfig.pushURL, name: "pushURL", privacy: .open)", in: .push)
            return
        }
        sendPushRegistrationDatails(to: url, deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handleFailedRegistration(application: application, error: error)
    }
}
