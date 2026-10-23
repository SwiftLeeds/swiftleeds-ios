import Dependencies
import Dispatch
import Foundation
import LogKit
import UIKit
import UserNotifications

extension AppDelegate {
    func requestPushAuthorization(application: UIApplication) {
        @Dependency(\.log) var log
        let notificatioNCenter = UNUserNotificationCenter.current()
        notificatioNCenter.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] isGranted, error in
            guard isGranted else {
                log.notice("Notification permission was declined", in: .push)
                return
            }
            if let error {
                log.error("Could not request notification permission: \(error, privacy: .open)", in: .push)
                return
            }

            notificatioNCenter.delegate = self

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    func sendPushRegistrationDatails(to url: URL, deviceToken: Data) {
        @Dependency(\.log) var log
        var details = TokenDetails(token: deviceToken)

        #if DEBUG
        details.debug = true
        #endif

        log.debug(
            "Registering for push with token \(deviceToken.map { String(format: "%02x", $0) }.joined(), name: "deviceToken", privacy: .hashed)",
            in: .push,
        )

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? TokenDetails.encoder.encode(details)

        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)

                let statusCode = (response as? HTTPURLResponse)?.statusCode

                // 399 may be a slip for 300 or 400, so the range gets a name once the bound is settled.
                // The disable sits above the line because the line has no room.
                // swiftlint:disable:next no_magic_numbers
                guard let statusCode, 200..<399 ~= statusCode else {
                    log.error(
                        "Push registration was rejected with status \(statusCode.map(String.init) ?? "none", name: "statusCode", privacy: .open)",
                        in: .push,
                    )
                    return
                }
            } catch {
                log.error("Push registration could not reach the server: \(error, privacy: .open)", in: .push)
            }
        }
    }

    /// Logs why the system refused to register this device for push notifications.
    ///
    /// - Parameter error: The error the system gave when registration failed.
    func handleFailedRegistration(error: Error) {
        @Dependency(\.log) var log
        log.error("The system refused push registration: \(error, privacy: .open)", in: .push)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        // The body has nothing to await. The completion-handler form would lift this.
    ) async -> UNNotificationPresentationOptions {  // swiftlint:disable:this async_without_await
        [.banner, .sound, .badge]
    }
}
