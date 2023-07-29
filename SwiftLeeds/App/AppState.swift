//
//  AppState.swift
//  SwiftLeeds
//
//  Created by karim ebrahim on 25/07/2023.
//

import Foundation
enum TabItems: Int {
    case conference, location, about, sponsors
}

final class AppState: ObservableObject {
    var selectedTab: TabItems = .conference
}
