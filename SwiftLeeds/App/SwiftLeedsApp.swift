//
//  SwiftLeedsApp.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI
import NetworkKit

@main
struct SwiftLeedsApp: App {
    private let network = Network(environment: SwiftLeedsEnvironment())

    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")
        URLCache.shared.diskCapacity = 100_000_000
    }

    var body: some Scene {
        WindowGroup {
            Tabs()
                .environment(\.network, network)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }
}

private extension SwiftLeedsApp {
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL, let components = URLComponents(
              url: incomingURL, resolvingAgainstBaseURL: true), let queryItems = components.queryItems
          else {
            return
        }
        print(queryItems)
    }
}
