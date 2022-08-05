//
//  ScheduleEndpoint.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 05/08/2022.
//

import NetworkKit

struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
    let method: HTTPMethod = .GET
}
