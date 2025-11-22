import WidgetKit
import SwiftUI

@main
struct SwiftLeedsWidget: Widget {
    let kind: String = "SwiftLeedsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftLeedsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SwiftLeeds What's up next?")
        .description("This widget to know what is the next talk on our stage.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
