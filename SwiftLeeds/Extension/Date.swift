import Foundation

extension Date {
    var withoutTimeAtConferenceVenue: Date {
        guard let date = Calendar.atConferenceVenue.date(from: Calendar.atConferenceVenue.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date")
        }

        return date
    }
}

private extension Calendar {
    static var atConferenceVenue: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = .init(abbreviation: "BST")!
        return calendar
    }
}
