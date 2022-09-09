//
//  AppDelegate+Push.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 04/09/2022.
//

import UIKit
import UserNotifications

extension AppDelegate {
    func requestPushAuthorization(application: UIApplication) {
        let notificatioNCenter = UNUserNotificationCenter.current()
        notificatioNCenter.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] isGranted, error in
            guard isGranted else { print("⛔️ not granted"); return }
            if let error = error { print("⛔️", error); return }

            notificatioNCenter.delegate = self

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    func sendPushRegistrationDatails(to url: URL, deviceToken: Data) {
        var details = TokenDetails(token: deviceToken)

#if DEBUG
        details.debug = true
        print("🚀", details)
#endif

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? TokenDetails.encoder.encode(details)

        URLSession.shared.dataTask(with: request).resume()
    }

    func handleFailedRegistration(application: UIApplication, error: Error) {
        print("⛔️", error)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
