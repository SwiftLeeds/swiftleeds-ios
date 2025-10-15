//
//  HttpMethod.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 24/09/2023.
//

import Foundation

public enum HttpMethod: Equatable {
    case get([URLQueryItem])
    case post(Data?)
    case head

    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .head: return "HEAD"
        }
    }
}
