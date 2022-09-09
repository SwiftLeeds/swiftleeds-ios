//
//  Network+Shared.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 09/09/2022.
//

import Foundation
import NetworkKit

/// Create a shared extension for inter op with UIKit
extension Network {
    static let shared = Network(environment: SwiftLeedsEnvironment())
}
