import SwiftUI
import WidgetKit

@main
struct SwiftLeedsWidget: Widget {
    let kind: String = Bundle.main.object(forInfoDictionaryKey: "WidgetKindName") as? String ?? "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftLeedsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("\(ConferenceConfig.conferenceName) What's up next?")
        .description("This widget to know what is the next talk on our stage.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
