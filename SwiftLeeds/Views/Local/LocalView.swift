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
    
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.89_02, longitude: 12.49_22), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Map(coordinateRegion: $mapRegion)
                    .ignoresSafeArea()
                BottomSheetView(isOpen: self.$bottomSheetShown, maxHeight: geometry.size.height * Constants.maxHeightRatio)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}
