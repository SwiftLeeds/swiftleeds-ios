//
//  SwiftLeedsAppClipApp.swift
//  SwiftLeedsAppClip
//
//  Created by Muralidharan Kathiresan on 25/08/22.
//

import SwiftUI
import NetworkKit

@main
struct SwiftLeedsAppClipApp: App {
    private let network = Network(environment: SwiftLeedsEnvironment())

    var body: some Scene {
        WindowGroup {
            MyConferenceView()
                .environment(\.network, network)
        }
    }
}
