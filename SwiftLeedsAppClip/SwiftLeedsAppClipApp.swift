import Dependencies
import NetworkKit
import SwiftUI

@main
struct SwiftLeedsAppClipApp: App {
    init() {
        prepareDependencies {
            $0.apiConfiguration = APIConfiguration(baseURL: ConferenceConfig.apiURL)
            $0.httpClient = HTTPClient.urlSession(.unauthenticated)
        }
    }

    var body: some Scene {
        WindowGroup {
            MyConferenceView()
        }
    }
}
