//
//  LocalEndpoint.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import NetworkKit

// MARK: - Schedule Endpoint
struct LocalEndpoint: Endpoint {
    typealias DataType = Local
    let path: String = "local"
}
