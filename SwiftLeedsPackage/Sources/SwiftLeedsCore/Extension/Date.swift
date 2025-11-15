//
//  Date.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 21/08/2023.
//

import Foundation

extension Date {
    var withoutTimeAtConferenceVenue: Date {
        guard let date = Calendar.atConferenceVenue.date(from: Calendar.atConferenceVenue.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date")
        }

        return date
    }
}
