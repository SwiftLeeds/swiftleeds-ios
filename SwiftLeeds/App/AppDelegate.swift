import Dependencies
import Foundation
import LogKit
import UIKit

/// The app's delegate, which handles launch and remote notification registration.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Asks for push authorization once the app has launched.
    func application(
        _ application: UIApplication,
        // UIApplicationDelegate declares the launch options dictionary, so it stays optional here.
        // The disable sits above the parameter rather than on it because the line has no room.
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil,
    ) -> Bool {
        requestPushAuthorization(application: application)

        return true
    }

    /// Sends the device token to the push server, or logs an error if the push URL is invalid.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        @Dependency(\.log) var log
        guard let url = URL(string: ConferenceConfig.pushURL) else {
            log.error(
                "The push URL is not a valid URL: \(ConferenceConfig.pushURL, name: "pushURL", privacy: .open)",
                in: .push,
            )
            return
        }
        sendPushRegistrationDatails(to: url, deviceToken: deviceToken)
    }

    /// Handles a failed remote notification registration.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handleFailedRegistration(error: error)
    }
}
