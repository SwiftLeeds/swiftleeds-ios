//
//  HeaderView.swift
//  SwiftLeeds
//
//  Created by Kannan Prasad on 05/07/2022.
//

import SwiftUI

struct FancyHeaderView: View {
    
    internal init(title: String, foregroundImageURL: URL?, backgroundImageURL: URL?) {
        self.title = title
        self.foregroundImageURL = foregroundImageURL
        self.backgroundImageURL = backgroundImageURL
        self.forgroundImageName = nil
        self.backgroundImageName = nil
    }
    
    internal init(title: String, forgroundImageName: String?, backgroundImageName: String?) {
        self.title = title
        self.foregroundImageURL = nil
        self.backgroundImageURL = nil
        self.forgroundImageName = forgroundImageName
        self.backgroundImageName = backgroundImageName
    }
    
    let title: String
    let foregroundImageURL: URL?
    let backgroundImageURL: URL?
    let forgroundImageName: String?
    let backgroundImageName: String?
    
    private let foregroundImageWidth = 160.0
    private let aspectRatio = 1.66
    var shadowColor: Color {
       Color.black.opacity(1/3)
    }
    
    @State var foregroudGroupViewHeight: CGFloat = .zero
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .edgesIgnoringSafeArea(.top)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(backgroundImage
                            .aspectRatio(contentMode: .fill))
            .overlay(foregroudGroup,alignment: .center)
            .padding(.bottom,foregroudGroupViewHeight/2)
    }
    
    private var backgroundImage: some View {
        if let backgroundImageURL = backgroundImageURL {
           return AnyView(AsyncImage(url: backgroundImageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    crateRectangleImage(for: image, aspectRatio: aspectRatio)
                case .failure(_):
                    AnyView(crateRectangleImage(for: Image(Assets.Image.playhouseImage),
                                           aspectRatio: aspectRatio))
                @unknown default:
                    ProgressView()
                        .tint(.white)
                        .opacity(0.5)
                }
            })
        } else if let backgroundImageName =  backgroundImageName {
            return AnyView(crateRectangleImage(for: Image(backgroundImageName),
                                          aspectRatio: aspectRatio))
        } else {
            return AnyView(crateRectangleImage(for: Image(Assets.Image.playhouseImage),
                                          aspectRatio: aspectRatio))
        }
    }
    
    private var foregroudGroup: some View {
        GeometryReader { geometry in
            VStack(spacing: Padding.stackGap){
                foregroundImage
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.subheadline.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(width: geometry.frame(in: .global).width,
                   height: geometry.frame(in: .global).height)
            .offset(y: geometry.size.height/2)
            .onAppear {
                foregroudGroupViewHeight = geometry.size.height
            }
            .onChange(of: geometry.size) { newValue in
                foregroudGroupViewHeight = newValue.height
            }
        }
    }
    
    private var foregroundImage: some View {
        if let foregroundImageURL = foregroundImageURL {
            return AnyView(AsyncImage(url: foregroundImageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success( let image):
                    crateRectangleImage(for: image, aspectRatio: aspectRatio)
                        .frame(width: foregroundImageWidth, height: foregroundImageWidth)
                        .cornerRadius(Constants.cellRadius)
                        .accessibilityHidden(true)
                case .failure(_):
                    crateRectangleImage(for: Image(Assets.Image.swiftLeedsIcon), aspectRatio: aspectRatio)
                @unknown default:
                    ProgressView()
                        .tint(.white)
                        .opacity(0.5)
                }
            })
        } else if let foregroundImageName = forgroundImageName {
            return AnyView(crateRectangleImage(for: Image(foregroundImageName),
                                       aspectRatio: aspectRatio))
        } else {
            return AnyView(crateRectangleImage(for: Image(Assets.Image.swiftLeedsIcon),
                                       aspectRatio: aspectRatio))
        }
    }
    
    private func crateRectangleImage(for image: Image, aspectRatio: Double) -> some View {
        return Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .background(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            )
    }
}

struct FancyHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        FancyHeaderView(title: "Steve Jobs",
                        forgroundImageName: Assets.Image.swiftLeedsIcon,
                        backgroundImageName: Assets.Image.playhouseImage)
            .frame(width: 200, height: 500, alignment: .center)
    }
}
