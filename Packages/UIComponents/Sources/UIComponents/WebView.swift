#if canImport(UIKit)
import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    private let urlString: String

    public init(url: String) {
        urlString = url
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
#endif
