import Foundation
enum TabItems: Int {
    case conference, location, about, sponsors, settings
}

final class AppState: ObservableObject {
    var selectedTab: TabItems = .conference
}
