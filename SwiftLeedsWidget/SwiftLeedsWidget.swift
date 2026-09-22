import Dependencies
import Foundation
import NetworkKit
import ScheduleFeature
import SwiftUI
import WidgetKit

@main
struct SwiftLeedsWidget: Widget {
    let kind: String = Bundle.main.object(forInfoDictionaryKey: "WidgetKindName") as? String ?? "Widget"

    init() {
        prepareDependencies {
            $0.apiConfiguration = APIConfiguration(baseURL: ConferenceConfig.apiURL)
            $0.httpClient = HTTPClient.urlSession(URLSession(configuration: .api()))
            $0.localScheduleStore = .appGroup(AppGroupIdentifier(ConferenceConfig.appGroupIdentifier))
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftLeedsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Text(verbatim: "\(ConferenceConfig.conferenceName) What's up next?"))
        .description("This widget to know what is the next talk on our stage.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
