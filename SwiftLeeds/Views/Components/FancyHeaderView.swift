import CachedAsyncImage
import DesignKit
import SharedAssets
import SwiftUI

struct FancyHeaderView: View {
    private let title: String
    private let foregroundImageURLs: [URL]
    private let foregroundImage: Image?

    private let foregroundImageWidth: Double = 160
    private let aspectRatio = 1.66

    @State private var foregroundGroupViewHeight: CGFloat = .zero

    init(
        title: String,
        foregroundImageURLs: [URL] = [],
        foregroundImage: Image? = nil
    ) {
        self.title = title
        self.foregroundImageURLs = foregroundImageURLs
        self.foregroundImage = foregroundImage
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .edgesIgnoringSafeArea(.top)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(
                createRectangleImage(for: Image.leedsPlayhouse, aspectRatio: aspectRatio)
                .aspectRatio(contentMode: .fill)
                .accessibilityHidden(true)
            )
            .overlay(foregroundGroup,alignment: .center)
            .padding(.bottom,foregroundGroupViewHeight/2)
    }
    
    private var foregroundGroup: some View {
        GeometryReader { geometry in
            VStack(spacing: Padding.cellGap) {
                foregroundImages
                    .frame(width: foregroundImageWidth * Double(foregroundImageCount))
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
    private var foregroundImages: some View {
        if foregroundImageURLs.isEmpty == false {
            HStack {
                ForEach(foregroundImageURLs, id: \.self) { foregroundImageURL in
                    AsyncImage(url: foregroundImageURL) { phase in
                        switch phase {
                        case .empty:
                            loadingView()
                        case .success(let image):
                            createRectangleImage(for: image)
                                .accessibilityHidden(true)
                        case .failure(_):
                            createRectangleImage(for: Image.swiftLeedsIcon)
                        @unknown default:
                            loadingView()
                        }
                    }
                }
            }
        } else if let foregroundImage = foregroundImage {
            createRectangleImage(for: foregroundImage)
        } else {
            createRectangleImage(for: Image.swiftLeedsIcon)
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

    private var foregroundImageCount: Int {
        let count = foregroundImageURLs.count + (foregroundImage == nil ? 0 : 1)
        // Ensure we always have at least 1 for the fallback image
        return count == 0 ? 1 : count
    }

    private var shadowColor: Color {
       Color.black.opacity(1/3)
    }
}

struct FancyHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Text(verbatim: "Local Asset")
                FancyHeaderView(
                    title: "Some Long Text here",
                    foregroundImage: Image.swiftLeedsIcon
                )
                Text(verbatim: "Remote Data")
                FancyHeaderView(
                    title: "Swift Taylor",
                    foregroundImageURLs: [URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338")!]
                )

            }
            ScrollView {
                Text(verbatim: "Local Asset")
                VStack {
                    FancyHeaderView(
                        title: "Kannan Prasad",
                        foregroundImage: Image.swiftLeedsIcon
                    )
                }
                Text(verbatim: "Remote Data")
                FancyHeaderView(
                    title: "Swift Taylor",
                    foregroundImageURLs: [
                        URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338")!
                    ]
                )
            }
        }
    }
}
