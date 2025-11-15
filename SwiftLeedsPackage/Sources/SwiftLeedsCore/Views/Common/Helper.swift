//
//  Helper.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 21/08/2023.
//

import Foundation

enum Helper {
    static var shortDateFormatter: DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-yyyy"
        return dateformatter
    }()
}
