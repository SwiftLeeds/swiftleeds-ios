//
//  ContentTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI

struct ContentTileView: View {
    let title: String
    let subTitle: String?
    let imageURL: URL?

    private let cornerRadius: CGFloat = 12


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            text
        }
        .background(Color.white, in: contentShape)
        .clipShape(contentShape)
    }

    private var image: some View {
        Rectangle()
            .aspectRatio(1.66, contentMode: .fit)
            .foregroundColor(.accentColor)
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.primary)
                .font(.subheadline.weight(.medium))
            if let subTitle = subTitle {
                Text(subTitle)
                    .foregroundColor(.secondary)
                    .font(.subheadline.weight(.regular))
            }
        }
        .padding()
        .frame(minHeight: 55)
    }

    private var contentShape: some Shape {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }
}

struct ContentTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgrond.edgesIgnoringSafeArea(.all)
            ContentTileView(
                title: "Alex Logan",
                subTitle: "subtitle",
                imageURL: URL(string: "https://pbs.twimg.com/profile_images/1475087054652559361/lgTnY96Q_400x400.jpg")
            )
            .padding()
        }
    }
}
