//
//  NetworkError.swift
//

import Foundation

public enum NetworkError: Int, Error {
    case badResponse = 0
    case badRequest = 400
    case notFound = 404
    case conflict = 409
    case offline = -1009
    case other
    case failedToDecode = 4864
    
    public init(from error: URLError) {
        self = NetworkError(rawValue: error.errorCode) ?? .other
    }

    public init(from errorCode: Int) {
        self = NetworkError(rawValue: errorCode) ?? .other
    }
}
