//
//  Local.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import Foundation

struct Local: Decodable {
    let data: [LocationCategory]

    struct LocationCategory: Decodable {
        let id: UUID
        let name: String
        let symbolName: String
        let locations: [Location]
    }

    struct Location: Decodable {
        let id: UUID
        let name: String
        let lat: Double
        let lon: Double
        let url: URL
    }
}
