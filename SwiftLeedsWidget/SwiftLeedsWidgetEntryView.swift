import Foundation
import ScheduleDomain
import SwiftUI
import WidgetKit

struct SwiftLeedsWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .systemSmall {
            SwiftLeedsSmallWidgetView(slot: entry.slot)
        } else if family == .systemMedium {
            SwiftLeedsMediumWidgetView(slot: entry.slot)
        }
    }
}

#Preview("Small", as: .systemSmall) {
    SwiftLeedsWidget()
} timeline: {
    SwiftLeedsWidgetEntry(
        date: .now,
        slot: Schedule.Slot(
            id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: Activity.lunch,
            presentation: Presentation.soloTalk,
        ),
    )
}

#Preview("Medium", as: .systemMedium) {
    SwiftLeedsWidget()
} timeline: {
    SwiftLeedsWidgetEntry(
        date: .now,
        slot: Schedule.Slot(
            id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: Activity.lunch,
            presentation: Presentation.soloTalk,
        ),
    )
}
