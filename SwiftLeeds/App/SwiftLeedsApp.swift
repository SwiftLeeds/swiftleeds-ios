//
//  SwiftLeedsApp.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

@main
struct SwiftLeedsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            Tabs()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate {
    static let pushURL: String = "https://www.swiftleeds.co.uk/push"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        URLCache.shared.diskCapacity = 100_000_000

        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")

        requestPushAuthorization(application: application)

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let url = URL(string: Self.pushURL) else { print("⛔️ Invalid push URL"); return }
        sendPushRegistrationDatails(to: url, deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("⛔️ Push registration failed:", error)
        handleFailedRegistration(application: application, error: error)
    }
}

private extension SwiftLeedsApp {
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL, let components = URLComponents(
              url: incomingURL, resolvingAgainstBaseURL: true), let queryItems = components.queryItems
        else { return }
        print(queryItems)
    }
}
