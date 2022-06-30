//
//  SwiftLeedsApp.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

@main
struct SwiftLeedsApp: App {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")
    }

    var body: some Scene {
        WindowGroup {
            Tabs()
        }
    }
}
