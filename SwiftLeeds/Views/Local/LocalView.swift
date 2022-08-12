//
//  LocalView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI
import MapKit
struct LocalView: View {
    @State private var bottomSheetShown = true
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.801277, longitude: -1.548567), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @StateObject private var model = LocalViewModel()

    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                Map(coordinateRegion: $mapRegion)
                    .ignoresSafeArea()
                BottomSheetView(
                    isOpen: self.$bottomSheetShown,
                    categories: model.categories,
                    error: model.error,
                    maxHeight: geometry.size.height * Constants.maxHeightRatio
                )
                if model.error != nil {
                    errorView
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .task {
            await model.loadData()
        }
    }

    var errorView: some View {
        Rectangle()
            .foregroundStyle(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack(alignment: .center, spacing: Padding.stackGap) {
                    Text("Something has gone wrong. Please try again later.")
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.center)
                    Button(action: { reload() }) {
                        Text("Reload")
                    }
                }
                .padding()
            )
    }

    private func reload() {
        Task(priority: .userInitiated) {
            await model.loadData()
        }
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}
