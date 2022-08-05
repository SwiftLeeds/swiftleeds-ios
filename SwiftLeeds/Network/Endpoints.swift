//
//  ScheduleEndpoint.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 05/08/2022.
//

import NetworkKit

// MARK: - Environment
struct SwiftLeedsEnvironment: NetworkEnvironmentProviding {
    let apiURL: String = "https://www.swiftleeds.co.uk/api/v1"
}

// MARK: - Schedule Endpoint
struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
}
