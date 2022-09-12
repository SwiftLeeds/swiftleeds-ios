//
//  WebView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 12/09/2022.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String

    init(url: String) {
        urlString = url
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
