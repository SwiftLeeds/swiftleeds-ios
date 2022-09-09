//
//  Endpoints.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 11/08/2022.
//

import NetworkKit

/// All endpoints should stay in this file to avoid creating lots of little files

// MARK: - Schedule Endpoint
struct ScheduleEndpoint: Endpoint {
    typealias DataType = Schedule
    let path: String = "api/v1/schedule"
}

// MARK: - Local Endpoint
struct LocalEndpoint: Endpoint {
    typealias DataType = Local
    let path: String = "api/v1/local"
}

// MARK: - Push Endpoint
struct PushEndpoint: Endpoint {
    typealias DataType = TokenResponse
    typealias BodyType = TokenDetails
    
    var path: String = "push"
    var method: HTTPMethod = .POST
    
    var body: TokenDetails

    init(tokenDetails: TokenDetails) {
        self.body = tokenDetails
    }
}
