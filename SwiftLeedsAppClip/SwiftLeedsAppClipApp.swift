//
//  SwiftLeedsAppClipApp.swift
//  SwiftLeedsAppClip
//
//  Created by Muralidharan Kathiresan on 03/10/22.
//

import SwiftUI
import NetworkKit

@main
struct SwiftLeedsAppClipApp: App {
    var body: some Scene {
        WindowGroup {
            MyConferenceView()
                .environment(\.network, network)
        }
    }
}
