import SwiftUI

/// A machine-readable code, drawn so that a scanner can read it.
///
/// The code comes from one of three sources: generated on device from a payload, supplied as an
/// image, or fetched from a URL. Generating needs no network, so it works offline.
///
/// ```swift
/// Barcode(.qr(slug))
/// Barcode(.code128("ABCD-1"))
/// Barcode(image: savedPass)
/// Barcode(url: remoteCode) { Text("We can't load the code") }
/// ```
///
/// The view keeps the code readable: it never smooths pixels when scaling up, and never
/// stretches, because a distorted code stops scanning. Use ``SwiftUICore/View/barcodeStyle(_:)``
/// for padding and shape.
package struct Barcode<Placeholder: View, Failure: View>: View {
    @Environment(\.barcodeStyle) private var style

    private let source: Source
    private let placeholder: () -> Placeholder
    private let failure: () -> Failure

    private enum Source {
        case generated(BarcodeContent)
        case supplied(Image)
        case remote(URL?)
    }

    private init(
        source: Source,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.source = source
        self.placeholder = placeholder
        self.failure = failure
    }

    package var body: some View {
        switch source {
        case .generated(let content):
            if let image = content.makeImage() {
                styled(scannable(Image(decorative: image, scale: 1)))
            } else {
                styled(AnyView(failure()))
            }
        case .supplied(let image):
            styled(scannable(image))
        case .remote(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    styled(scannable(image))
                case .failure:
                    styled(AnyView(failure()))
                case .empty:
                    styled(AnyView(placeholder()))
                @unknown default:
                    styled(AnyView(placeholder()))
                }
            }
        }
    }

    private func scannable(_ image: Image) -> AnyView {
        AnyView(
            image
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        )
    }

    private func styled(_ code: AnyView) -> some View {
        style.makeBody(
            BarcodeStyleConfiguration(code: BarcodeStyleConfiguration.Code(base: code))
        )
    }
}

package extension Barcode {
    /// Creates a code fetched from `url`.
    ///
    /// - Parameters:
    ///   - url: Where to fetch the code image from.
    ///   - placeholder: Shown while fetching.
    ///   - failure: Shown if the fetch fails.
    init(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.init(source: .remote(url), placeholder: placeholder, failure: failure)
    }
}

package extension Barcode where Placeholder == Failure {
    /// Creates a code fetched from `url`, showing `fallback` both while fetching and on failure.
    init(url: URL?, @ViewBuilder fallback: @escaping () -> Failure) {
        self.init(source: .remote(url), placeholder: fallback, failure: fallback)
    }
}

package extension Barcode where Placeholder == EmptyView {
    /// Creates a code generated from `content`, showing `failure` if it cannot be encoded.
    init(_ content: BarcodeContent, @ViewBuilder failure: @escaping () -> Failure) {
        self.init(source: .generated(content), placeholder: { EmptyView() }, failure: failure)
    }
}

package extension Barcode where Placeholder == EmptyView, Failure == EmptyView {
    /// Creates a code generated from `content`, showing nothing if it cannot be encoded.
    init(_ content: BarcodeContent) {
        self.init(source: .generated(content), placeholder: { EmptyView() }, failure: { EmptyView() })
    }

    /// Creates a code from an image you already have.
    init(image: Image) {
        self.init(source: .supplied(image), placeholder: { EmptyView() }, failure: { EmptyView() })
    }
}

#Preview("Symbologies") {
    VStack(spacing: 24) {
        Barcode(.qr("ti_pxqFKr9pPWd6VeYKvMBKpjQ"))
            .frame(width: 160, height: 160)

        Barcode(.code128("ABCD-1"))
            .frame(width: 220, height: 80)
    }
    .padding()
}

#Preview("Plain style") {
    Barcode(.qr("ti_pxqFKr9pPWd6VeYKvMBKpjQ"))
        .barcodeStyle(.plain)
        .frame(width: 160, height: 160)
        .padding()
}

#Preview("Cannot encode") {
    Barcode(.code128("café-ticket-✓")) {
        Label("We can't show the code", systemImage: "exclamationmark.triangle")
    }
    .frame(width: 220, height: 80)
    .padding()
}
