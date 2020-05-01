//
//  WebViewModel.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Combine
import WebKit

class WebViewModel: ObservableObject {

    @Published var webView = WKWebView()

    @Published var showActivity = false

    @Published var prgress: Float = 0

    @Published var panel: Panel?

    @Published var inputTextPanel: InputTextPanel?

    private var observers = [NSKeyValueObservation]()

    public init() {
        observeWebViewStates(\.estimatedProgress)
        observeWebViewStates(\.title)
        observeWebViewStates(\.url)
        observeWebViewStates(\.canGoBack)
        observeWebViewStates(\.canGoForward)
    }

    private func observeWebViewStates<Value>(_ keyPath: KeyPath<WKWebView, Value>) {
        observers.append(webView.observe(keyPath, options: .prior) { (_, _) in
            self.objectWillChange.send()
        })
    }

}
