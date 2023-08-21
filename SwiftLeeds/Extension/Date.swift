//
//  Date.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 21/08/2023.
//

import Foundation

extension Date {
    var withoutTime: Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date")
        }

        return date
    }
}
