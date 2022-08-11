//
//  Endpoints.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 11/08/2022.
//

import NetworkKit

// MARK: - Schedule Endpoint
struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
}

// MARK: - Local Endpoint
struct LocalEndpoint: Endpoint {
    typealias DataType = Local
    let path: String = "local"
}
