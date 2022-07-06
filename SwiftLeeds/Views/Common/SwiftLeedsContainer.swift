//
//  SwiftLeedsContainer.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI

struct SwiftLeedsContainer<Content: View>: View {
    private var content: () -> (Content)

    init(@ViewBuilder content: @escaping () -> (Content)) {
        self.content = content
    }

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            content()
        }
    }
}

struct SwiftLeedsContainer_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsContainer {
            Text("SwiftLeeds 22")
        }
    }
}
