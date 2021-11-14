//
//  ContentView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.background
            
            Text("Hello, Swift Leeds!")
                .font(.custom("Helvetica Neue", size: 26, relativeTo: .title))
                .foregroundColor(.white)
                .padding()
        }
        .ignoresSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
