import Foundation
import ScheduleDomain
import ScheduleFeature
import WidgetKit

struct SwiftLeedsWidgetEntry: TimelineEntry {
    var date: Date
    let slot: Schedule.Slot
}
