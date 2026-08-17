import Dependencies
import LogKit
import UIKit
import UserNotifications

private let push: LogCategory = "push"

extension AppDelegate {
    func requestPushAuthorization(application: UIApplication) {
        @Dependency(\.log) var log
        let notificatioNCenter = UNUserNotificationCenter.current()
        notificatioNCenter.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] isGranted, error in
            guard isGranted else {
                log(.notice, push, "Notification permission was declined")
                return
            }
            if let error {
                log(.error, push, "Could not request notification permission",
                    .open("error", error))
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

        log(.debug, push, "Registering for push",
            .hashed("deviceToken", deviceToken.map { String(format: "%02x", $0) }.joined()))

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? TokenDetails.encoder.encode(details)

        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)

                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<399 ~= statusCode else {
                    log(.error, push, "Push registration was rejected",
                        .open("statusCode", (response as? HTTPURLResponse)?.statusCode ?? -1))
                    return
                }
            } catch {
                log(.error, push, "Push registration could not reach the server",
                    .open("error", error))
            }
        }
    }

    func handleFailedRegistration(application: UIApplication, error: Error) {
        @Dependency(\.log) var log
        log(.error, push, "The system refused push registration",
            .open("error", error))
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
