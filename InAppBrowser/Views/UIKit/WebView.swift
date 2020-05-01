//
//  WebView.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    var url: URL

    var urlHandlers = [URLHandler]()

    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let uiView = viewModel.webView
        uiView.uiDelegate = context.coordinator
        uiView.navigationDelegate = context.coordinator
        uiView.load(URLRequest(url: url))
        return uiView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

    // MARK: - Coordinator Classs

    class Coordinator: NSObject  {

        private var view: WebView

        init(_ view: WebView) {
            self.view = view
        }

    }

}

// MARK: - WebView Navigation delegate

extension WebView.Coordinator: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let urlHandler = view.urlHandlers.first(where: { $0.canHandle(url) }) {
                urlHandler.handle(url, viewController: mostFrontViewController())
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }

    // MARK: - Autholication Challenges

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            // Show alert dialog
            let message = String(format: NSLocalizedString("Log in to %@", comment: ""), webView.url?.host ?? "site")

            let items = [
                InputeTextItem(placeholder: "User Name"),
                InputeTextItem(placeholder: "Password", isSecure: true),
            ]

            view.viewModel.inputTextPanel = InputTextPanel(message: message, items: items, handler: { (values) in
                if let values = values {
                    let credential = URLCredential(user: values[0],
                                                   password: values[1],
                                                   persistence: .forSession)
                    completionHandler(.useCredential, credential)

                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            })

            return
        }

        completionHandler(.performDefaultHandling, nil)
    }

    // MARK: - Reacting to Errors

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        view.viewModel.panel = Panel(message: error.localizedDescription, type: .alert({}))
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        view.viewModel.panel = Panel(message: error.localizedDescription, type: .alert({}))
    }
}

// MARK: - WebView UI delegate

extension WebView.Coordinator: WKUIDelegate {

    // MARK: - Creating a Web View

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }

        return nil
    }

    // MARK: - Displaying UI Panels

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        view.viewModel.panel = Panel(message: message, type: .alert(completionHandler))
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        view.viewModel.panel = Panel(message: message, type: .confirm(completionHandler))
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let items = [InputeTextItem(placeholder: "Enter Text")]

        view.viewModel.inputTextPanel = InputTextPanel(message: prompt, items: items, handler: { (values) in
            completionHandler(values?.first)
        })
    }

}
