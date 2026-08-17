import Dependencies
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
            in: .push
        )

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? TokenDetails.encoder.encode(details)

        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)

                let statusCode = (response as? HTTPURLResponse)?.statusCode

                guard let statusCode, 200..<399 ~= statusCode else {
                    log.error(
                        "Push registration was rejected with status \(statusCode.map(String.init) ?? "none", name: "statusCode", privacy: .open)",
                        in: .push
                    )
                    return
                }
            } catch {
                log.error("Push registration could not reach the server: \(error, privacy: .open)", in: .push)
            }
        }
    }

    func handleFailedRegistration(application: UIApplication, error: Error) {
        @Dependency(\.log) var log
        log.error("The system refused push registration: \(error, privacy: .open)", in: .push)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
