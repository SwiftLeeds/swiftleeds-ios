//
//  DateFormatters.swift
//

import Foundation

struct DateFormatters {
    // 2022-06-22
    static var shortDateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-mm-dd"
        return dateformatter
    }
    
    // Sunday, Feb 6, 2022
    static var writtenDateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateformatter
    }
}
