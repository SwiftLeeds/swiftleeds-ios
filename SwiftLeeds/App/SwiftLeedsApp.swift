import AuthenticationApplication
import AuthenticationInfrastructure
import Dependencies
import Foundation
import LogKit
import LogKitUnified
import NetworkKit
import ScheduleInfrastructure
import SecureStorageKit
import SecureStorageKitKeychain
import SwiftUI
import UITheme

@main
struct SwiftLeedsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var appState = AppState()

    /// The disk limit for the shared cache, which holds mostly remote images.
    private static let sharedURLCacheDiskCapacityInBytes = 100_000_000

    init() {
        Self.sizeSharedURLCache()
        prepareDependencies {
            // A fresh salt each launch, so hashed values correlate within a session but never
            // between them. Without a subsystem there is no honest place to write (this ships
            // as two apps), so nothing is written rather than guessing at one.
            $0.log =
                Bundle.main.bundleIdentifier
                .flatMap { try? LogSubsystem($0) }
                .map { Log.unified(subsystem: $0, salt: .random()) }
                ?? .silent
            $0.secureStorage = .keychain(service: KeychainService("uk.co.swiftleeds.authentication"))
            $0.apiConfiguration = APIConfiguration(baseURL: URL(string: "https://\(ConferenceConfig.apiHost)")!)
            $0.httpClient = HTTPClient.urlSession(.unauthenticated).logging()
            $0.localScheduleStore = .appGroup(AppGroupIdentifier(ConferenceConfig.appGroupIdentifier))
            $0.authHTTPClient = .live(
                urlSession: .authenticated,
                onSessionExpiry: {
                    @Dependency(\.signOut) var signOut
                    try? await signOut()
                },
            )
            $0.signIn = SignIn.liveValue.logging()
            $0.signOut = SignOut.liveValue.logging()
            $0.fetchProfile = FetchProfile.liveValue.logging()
        }
    }

    var body: some Scene {
        WindowGroup {
            Tabs()
                .environmentObject(appState)
                .applyingSelectedTheme()
        }
    }

    /// Gives the shared URL cache room on disk for remote images.
    private static func sizeSharedURLCache() {
        URLCache.shared.diskCapacity = sharedURLCacheDiskCapacityInBytes
    }
}
