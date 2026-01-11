import Foundation
enum TabItems: Int {
    case conference
    case location
    case about
    case sponsors
    case settings
}

final class AppState: ObservableObject {
    var selectedTab: TabItems = .conference
}
