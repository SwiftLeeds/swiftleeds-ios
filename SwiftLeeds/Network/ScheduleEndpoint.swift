//
//  ScheduleEndpoint.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 05/08/2022.
//

import NetworkKit

// MARK: - Schedule Endpoint
struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
}
