import Foundation
import SwiftUI

/// A view that shows a company's mark, fitted whole inside its frame.
///
/// The mark loads from `url`. It keeps its proportions, so a wide mark leaves
/// space above and below it rather than being cropped or stretched. The frame
/// is the caller's, and a screen scales it with `@ScaledMetric`.
///
/// ```swift
/// Logo(url: sponsor.logoURL)
///     .frame(width: 56, height: 56)
/// ```
public struct Logo<Fallback: View>: View {
    /// Where the mark comes from.
    private enum Source {
        /// The caller provided no URL.
        case noLogo

        /// The mark loads from this URL.
        case url(URL)
    }

    /// Where the mark comes from.
    private let source: Source

    /// The mark fitted to the frame, or nothing while it loads.
    public var body: some View {
        switch source {
        case .noLogo:
            EmptyView()

        case .url(let url):
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

extension Logo where Fallback == EmptyView {
    /// Creates a logo that loads its mark from a URL.
    ///
    /// - Parameter url: Where the mark loads from. A `nil` url draws nothing and asks for nothing.
    public init(url: URL?) {
        source = url.map(Source.url) ?? .noLogo
    }
}
