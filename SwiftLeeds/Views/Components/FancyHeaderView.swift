//
//  HeaderView.swift
//  SwiftLeeds
//
//  Created by Kannan Prasad on 05/07/2022.
//

import SwiftUI
import CachedAsyncImage

struct FancyHeaderView: View {
    internal init(
        title: String,
        foregroundImageURL: URL? = nil,
        backgroundImageURL: URL? = nil,
        foregroundImageName: String? = nil,
        backgroundImageName: String? = nil
    ) {
        self.title = title
        self.foregroundImageURL = foregroundImageURL
        self.backgroundImageURL = backgroundImageURL
        self.foregroundImageName = foregroundImageName
        self.backgroundImageName = backgroundImageName
    }

    // MARK: Convenience Initialisers
    internal init(title: String, foregroundImageURL: URL?, backgroundImageURL: URL?) {
        self.title = title
        self.foregroundImageURL = foregroundImageURL
        self.backgroundImageURL = backgroundImageURL
        self.foregroundImageName = nil
        self.backgroundImageName = nil
    }
    
    internal init(title: String, foregroundImageName: String?, backgroundImageName: String?) {
        self.title = title
        self.foregroundImageURL = nil
        self.backgroundImageURL = nil
        self.foregroundImageName = foregroundImageName
        self.backgroundImageName = backgroundImageName
    }
    
    let title: String
    let foregroundImageURL: URL?
    let backgroundImageURL: URL?
    let foregroundImageName: String?
    let backgroundImageName: String?
    
    private let foregroundImageWidth = 160.0
    private let aspectRatio = 1.66
    var shadowColor: Color {
       Color.black.opacity(1/3)
    }
    
    @State var foregroundGroupViewHeight: CGFloat = .zero
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .edgesIgnoringSafeArea(.top)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(backgroundImage
                            .aspectRatio(contentMode: .fill))
            .overlay(foregroundGroup,alignment: .center)
            .padding(.bottom,foregroundGroupViewHeight/2)
    }
     
    
    @ViewBuilder
    private var backgroundImage: some View {
        if let backgroundImageURL = backgroundImageURL {
           CachedAsyncImage(url: backgroundImageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    createRectangleImage(for: image, aspectRatio: aspectRatio)
                case .failure(_):
                    createRectangleImage(for: Image(Assets.Image.playhouseImage),
                                           aspectRatio: aspectRatio)
                @unknown default:
                    ProgressView()
                        .tint(.white)
                        .opacity(0.5)
                }
            }
        } else if let backgroundImageName =  backgroundImageName {
            createRectangleImage(for: Image(backgroundImageName),
                                          aspectRatio: aspectRatio)
        } else {
            createRectangleImage(for: Image(Assets.Image.playhouseImage),
                                          aspectRatio: aspectRatio)
        }
    }
    
    private var foregroundGroup: some View {
        GeometryReader { geometry in
            VStack(spacing: Padding.cellGap) {
                foregroundImage
                    .frame(width: foregroundImageWidth)
                    .cornerRadius(Constants.cellRadius)
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.title3.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(width: geometry.frame(in: .global).width,
                   height: geometry.frame(in: .global).height)
            .offset(y: geometry.size.height/2)
            .onAppear {
                foregroundGroupViewHeight = geometry.size.height
            }
            .onChange(of: geometry.size) { newValue in
                foregroundGroupViewHeight = newValue.height
            }
        }
    }
    
    @ViewBuilder
    private var foregroundImage: some View {
        if let foregroundImageURL = foregroundImageURL {
           AsyncImage(url: foregroundImageURL) { phase in
                switch phase {
                case .empty:
                    loadingView()
                case .success( let image):
                    createRectangleImage(for: image)
                        .accessibilityHidden(true)
                case .failure(_):
                    createRectangleImage(for: Image(Assets.Image.swiftLeedsIcon))
                @unknown default:
                    loadingView()
                }
            }
        } else if let foregroundImageName = foregroundImageName {
            createRectangleImage(for: Image(foregroundImageName))
        } else {
            createRectangleImage(for: Image(Assets.Image.swiftLeedsIcon))
        }
    }
    
    private func createRectangleImage(for image: Image, aspectRatio: Double = 1.0) -> some View {
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

    private func loadingView(aspectRatio: Double = 1.0) -> some View {
        return Rectangle()
            .foregroundColor(.secondary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                ProgressView()
            )
            .progressViewStyle(CircularProgressViewStyle())
    }
}

struct FancyHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Text("Local Asset")
                FancyHeaderView(title: "Some Long Text here",
                                foregroundImageName: Assets.Image.swiftLeedsIcon,
                                backgroundImageName: Assets.Image.playhouseImage)
                Text("Remote Data")
                FancyHeaderView(title: "Swift Taylor",
                                foregroundImageURL: URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338")!,
                                backgroundImageURL: URL(string:"https://www.nycgo.com/images/itineraries/42961/soc_fb_dumbo_spots__facebook.jpg")!)

            }
            ScrollView {
                Text("Local Asset")
                VStack {
                    FancyHeaderView(title: "Kannan Prasad",
                                    foregroundImageName: Assets.Image.swiftLeedsIcon,
                                    backgroundImageName: Assets.Image.playhouseImage)
                }
                Text("Remote Data")
                FancyHeaderView(title: "Swift Taylor",
                                foregroundImageURL: URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338")!,
                                backgroundImageURL: URL(string:"https://www.nycgo.com/images/itineraries/42961/soc_fb_dumbo_spots__facebook.jpg")!)
            }
        }
    }
}
