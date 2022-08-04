//
//  SwiftLeedsEnvironment.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 22/07/2022.
//

import Foundation
import NetworkKit

struct SwiftLeedsEnvironment: NetworkEnvironmentProviding {
    let apiUrl: String = "https://www.swiftleeds.co.uk/api/v1"
}

struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
    let method: HTTPMethod = .GET
}
