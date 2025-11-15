//
//  Requests.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 24/09/2023.
//

import Foundation

enum Requests {
    private static let host = "swiftleeds.co.uk"
    private static let apiVersion1 = "/api/v1"
    private static let apiVersion2 = "/api/v2"

    static let schedule = Request<Schedule>(
        host: host,
        path: "\(apiVersion2)/schedule",
        eTagKey: "etag-schedule"
    )

    static let local = Request<Local>(
        host: host,
        path: "\(apiVersion1)/local",
        eTagKey: "etag-local"
    )

    static let sponsors = Request<Sponsors>(
        host: host,
        path: "\(apiVersion1)/sponsors",
        eTagKey: "etag-sponsors"
    )

    static let team = Request<Team>(
        host: host,
        path: "\(apiVersion2)/team",
        eTagKey: "etag-team"
    )

    static func schedule(for eventID: UUID) -> Request<Schedule> {
        Request<Schedule>(
            host: host,
            path: "\(apiVersion2)/schedule",
            method: .get([.init(
                name: "event",
                value: eventID.uuidString)
            ]),
            eTagKey: "etag-schedule-\(eventID.uuidString)"
        )
    }

    static var defaultDateDecodingStratergy: JSONDecoder.DateDecodingStrategy = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return .formatted(dateFormatter)
    }()

    // Custom strategy for v2 schedule endpoint (handles both ISO8601 and dd-MM-yyyy)
    static var scheduleDateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 first (for slot dates)
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            // Fallback to dd-MM-yyyy format (for event dates)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            if let date = formatter.date(from: dateString) {
                return date
            }

            // If neither works, throw an error
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected format. Expected ISO8601 or dd-MM-yyyy, got: \(dateString)"
            )
        }
    }()
}
