//
//  Requests.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 24/09/2023.
//

import Foundation

enum Requests {
    private static let host = "swiftleeds.co.uk"
    private static let apiPath = "/api/v1"

    static let schedule = Request<Schedule>(host: host, path: "\(apiPath)/schedule", eTagKey: "etag-schedule")
    static let local = Request<Local>(host: host, path: "\(apiPath)/local", eTagKey: "etag-local")
    static let sponsors = Request<Sponsors>(host: host, path: "\(apiPath)/sponsors", eTagKey: "etag-sponsors")

    static func schedule(for eventID: UUID) -> Request<Schedule> {
        Request<Schedule>(host: host, path: "\(apiPath)/schedule", method: .get([.init(name: "event", value: eventID.uuidString)]), eTagKey: "etag-schedule-\(eventID.uuidString)")
    }

    static var defaultDateDecodingStratergy: JSONDecoder.DateDecodingStrategy = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return .formatted(dateFormatter)
    }()
}
