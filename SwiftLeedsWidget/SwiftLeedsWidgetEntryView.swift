import WidgetKit
import SwiftUI

struct SwiftLeedsWidgetEntryView : View {
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

struct SwiftLeedsWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsWidgetEntryView(entry: SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: Activity.lunch, presentation: Presentation.donnyWalls)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        SwiftLeedsWidgetEntryView(entry: SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: Activity.lunch, presentation: Presentation.donnyWalls)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

