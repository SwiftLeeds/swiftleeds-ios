//
//  Endpoints.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 11/08/2022.
//

import Foundation
import NetworkKit

/// All endpoints should stay in this file to avoid creating lots of little files

// MARK: - Schedule Endpoint
struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "schedule"
    var eventID: String?

    var queryParameters: [URLQueryItem] {
        if let eventID {
            return [.init(name: "event", value: eventID)]
        } else {
            return []
        }
    }
}

// MARK: - Local Endpoint
struct LocalEndpoint: Endpoint {
    typealias DataType = Local
    let path: String = "local"
}

// MARK: - Sponsors Endpoint
struct SponsorsEndpoint: Endpoint {
    typealias DataType = Sponsors
    let path: String = "sponsors"
}
