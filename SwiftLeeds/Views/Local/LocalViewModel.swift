//
//  LocalViewModel.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import Foundation
import NetworkKit
import SwiftUI
import MapKit

class LocalViewModel: ObservableObject {
    @Published var selectedCategory: Local.LocationCategory?
    @Published var categories: [Local.LocationCategory] = []

    @Environment(\.network) var network: Networking

    var error: Error?
    
    func loadData() async {
        do {
            let localResults = try await network.performRequest(endpoint: LocalEndpoint())

            DispatchQueue.main.async {
                self.categories = localResults.data
                self.selectedCategory = self.categories.first
            }
        } catch {
            self.error = error
        }

        await publishResults()
    }

    var annotationItem: Local.Location {
        Local.Location(id: UUID(), name: "SwiftLeeds", url: URL(string: "httos://www.swiftleeds.co.uk")!, location: CLLocation(latitude: 53.798228, longitude: -1.535243))
    }

    @MainActor
    private func publishResults() {
        self.objectWillChange.send()
    }
}
