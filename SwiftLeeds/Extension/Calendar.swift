import Foundation

extension Calendar {
    static var atConferenceVenue: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = .init(abbreviation: "BST")!
        return calendar
    }
}
