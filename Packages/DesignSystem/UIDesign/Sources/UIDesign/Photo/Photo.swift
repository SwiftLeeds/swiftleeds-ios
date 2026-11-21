import SwiftUI

/// A view that shows a picture from a URL, filling its frame and cropped to it.
///
/// The picture loads from `url`. It fills the frame its caller gives it, and
/// whatever overflows the frame is cut off, so a photo never pushes its
/// neighbors aside.
///
/// ```swift
/// Photo(url: venue.photoURL)
///     .frame(width: 100, height: 150)
/// ```
public struct Photo<Fallback: View>: View {
    /// Where the picture loads from.
    private let url: URL?

    public var body: some View {
        Color.clear
            .overlay { picture }
            .clipped()
    }

    /// The loaded picture, scaled to fill the frame.
    private var picture: some View {
        AsyncImage(url: url) { phase in
            if case .success(let image) = phase {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

extension Photo where Fallback == EmptyView {
    /// Creates a photo that loads its picture from a URL.
    ///
    /// - Parameter url: Where the picture loads from.
    public init(url: URL?) {
        self.url = url
    }
}
