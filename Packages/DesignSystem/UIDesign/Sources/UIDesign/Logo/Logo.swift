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

    /// A view that draws a logo in a given style.
    private struct ResolvedLogoStyle<Style: LogoStyle>: View {
        /// The style that draws the logo.
        let style: Style

        /// The properties of the logo.
        let configuration: LogoStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current logo style.
    @Environment(\.logoStyle) private var style

    /// Where the mark comes from.
    private let source: Source

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current logo style.
    private var configuration: LogoStyleConfiguration {
        LogoStyleConfiguration(content: content)
    }

    /// The mark fitted to the frame, or nothing while it loads.
    @ViewBuilder
    private var content: some View {
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

    /// Returns a view that draws the logo in the given style.
    ///
    /// - Parameter style: The style to draw the logo in.
    /// - Returns: A view that draws the logo in `style`.
    private func resolved(in style: some LogoStyle) -> some View {
        ResolvedLogoStyle(style: style, configuration: configuration)
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
