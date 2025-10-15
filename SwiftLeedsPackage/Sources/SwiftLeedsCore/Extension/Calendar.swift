//
//  Calendar.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 04/08/2022.
//

import Foundation

extension Calendar {
    func numberOfDays(to date: Date) -> Int {
        let fromDate = startOfDay(for: Date.now)
        let toDate = startOfDay(for: date)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day ?? 0
    }
    
    static var atConferenceVenue: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = .init(abbreviation: "BST")!
        return calendar
    }
}
