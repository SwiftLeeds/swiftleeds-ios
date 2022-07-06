//
//  ContentTileView.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import SwiftUI

struct ContentTileView: View {
    // Label to be read prior to the content, i.e Sponsor
    let accessibilityLabel: String
    let title: String
    let subTitle: String?
    let imageURL: URL?

    var placeholderColor: Color = .accentColor
    var imageBackgroundColor: Color = .accentColor
    var imageContentMode: ContentMode = .fill

    let onTap: () -> ()


    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                image
                text
            }
        }
        .background(Color.cellBackground, in: contentShape)
        .clipShape(contentShape)
        .buttonStyle(SquishyButtonStyle())
    }

    private var image: some View {
        AsyncImage(
            url: imageURL,
            content: { image in
                Rectangle()
                    .aspectRatio(1.66, contentMode: .fill)
                    .foregroundColor(.clear)
                    .background(
                        image
                            .resizable()
                            .aspectRatio(contentMode: imageContentMode)
                            .transition(.opacity)
                    )
                    .background(imageBackgroundColor)
                    .clipped()
                    .transition(contentTransition)
            },
            placeholder: {
                Rectangle()
                    .foregroundColor(placeholderColor)
                    .transition(contentTransition)
                    .overlay(content: {
                        ProgressView()
                            .tint(.white)
                            .opacity(0.5)
                    })
            }
        )
        .aspectRatio(1.66, contentMode: .fit)
        .accessibilityHidden(true)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(accessibilityLabel), \(title) \(subTitle ?? "")"
        )
        .padding()
        .frame(minHeight: 55)
    }

    private var contentShape: some Shape {
        RoundedRectangle(cornerRadius: Constants.cellRadius, style: .continuous)
    }

    private var contentTransition: AnyTransition {
        .opacity.animation(.spring())
    }
}

struct ContentTileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack {
                ContentTileView(
                    accessibilityLabel: "Speaker",
                    title: "Alex Logan",
                    subTitle: "subtitle",
                    imageURL: URL(string: "https://pbs.twimg.com/profile_images/1475087054652559361/lgTnY96Q_400x400.jpg"),
                    onTap: {}
                )
                ContentTileView(
                    accessibilityLabel: "Speaker",
                    title: "Alex Logan",
                    subTitle: nil,
                    imageURL: nil,
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
