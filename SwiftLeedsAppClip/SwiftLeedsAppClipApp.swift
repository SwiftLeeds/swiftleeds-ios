import Dependencies
import Foundation
import NetworkKit
import ScheduleUI
import SwiftUI

@main
struct SwiftLeedsAppClipApp: App {
    init() {
        prepareDependencies {
            $0.apiConfiguration = APIConfiguration(baseURL: ConferenceConfig.apiURL)
            $0.httpClient = HTTPClient.urlSession(URLSession(configuration: .api()))
        }
    }

    var body: some Scene {
        WindowGroup {
            ScheduleView()
        }
    }
}
