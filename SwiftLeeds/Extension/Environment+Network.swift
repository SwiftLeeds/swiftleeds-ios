//
//  Environment+Network.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import SwiftUI
import NetworkKit

// MARK: - Network
@available(iOS 13.0, *)
struct NetworkKey: EnvironmentKey {
    static let defaultValue: Networking = Network(environment: SwiftLeedsEnvironment())
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var network: Networking {
        get { self[NetworkKey.self] }
        set { self[NetworkKey.self] = newValue }
    }
}
