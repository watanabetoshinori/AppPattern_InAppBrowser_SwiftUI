//
//  InAppBrowser.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import WebKit

struct InAppBrowser: View {

    @Environment(\.presentationMode) var presentationMode

    @State var url: URL

    @ObservedObject private var webViewModel = WebViewModel()

    @State var listItem = [WKBackForwardListItem]()

    @State var showList = false

    var body: some View {

        // Buttons

        let doneButton =
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }

        let stopButton =
            Button(action: {
                self.webViewModel.webView.stopLoading()
            }) {
                Image(systemName: "xmark")
            }

        let reloadButton =
            Button(action: {
                self.webViewModel.webView.reload()
            }) {
                Image(systemName: "arrow.clockwise")
            }

        let backButton =
            Button(action: {
                self.webViewModel.webView.goBack()
            }) {
                Image(systemName: "chevron.left")
            }
            .simultaneousGesture(LongPressGesture().onEnded({ _ in
                self.listItem = Array(self.webViewModel.webView.backForwardList.backList.reversed())
                self.showList = true
            }))
            .disabled(!webViewModel.webView.canGoBack)

        let forwardButton =
            Button(action: {
                self.webViewModel.webView.goForward()
            }) {
                Image(systemName: "chevron.right")
            }
            .simultaneousGesture(LongPressGesture().onEnded({ _ in
                self.listItem = self.webViewModel.webView.backForwardList.forwardList
                self.showList = true
            }))
            .disabled(!webViewModel.webView.canGoForward)

        let actionButton =
            Button(action: {
                self.webViewModel.showActivity = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: self.$webViewModel.showActivity) {
                ActivityViewController(item: self.webViewModel.webView.url)
            }

        let safariButton =
            Button(action: {
                UIApplication.shared.open(self.webViewModel.webView.url!, options: [:]) { (result) in
                    if result == false {
                        print("Can't open URL by Safari.")
                    }
                }
            }) {
                Image(systemName: "safari")
            }
            .disabled(webViewModel.webView.url == nil)

        let developerToolButton =
            Button(action: {
                self.webViewModel.webView.evaluateJavaScript(InAppBrowserSettings.shared.debugTool.javascript, completionHandler: nil)
            }) {
                Image(systemName: "hammer")
            }
            .disabled(webViewModel.webView.url == nil)

        // Toolbar

        let toolbar =
            HStack {
                backButton
                Spacer()
                forwardButton
                Spacer()
                actionButton
                Spacer()
                safariButton
                Spacer()
                developerToolButton
            }

        // MainView

        return VStack {
            ZStack {
                // WebView
                WebView(url: self.url, urlHandlers: [iTunesURLHandler()], viewModel: self.webViewModel)
                    .alert(item: self.$webViewModel.panel, content: showPanel)
                    .sheet(isPresented: self.$showList) { InAppBrowserBackForwardList(webView: self.$webViewModel.webView, items: self.listItem) }
                    .onReceive(self.webViewModel.$inputTextPanel.receive(on: RunLoop.main), perform: showInputTextPanel)

                // Progress Indicator
                VStack {
                    ProgressView(progress: Float(self.webViewModel.webView.estimatedProgress))
                        .frame(height: 2)
                        .opacity(self.webViewModel.webView.estimatedProgress < 1 ? 1 : 0)

                    Spacer()
                }
            }
            toolbar
                .padding()
        }
        .navigationBarTitle(
            Text(self.webViewModel.webView.url?.scheme?.lowercased() == "https" ? "" : "Not Secure -") +
            Text(self.webViewModel.webView.title ?? "Unknown"),
            displayMode: .inline)
        .navigationBarItems(leading: doneButton,
                            trailing: webViewModel.webView.isLoading ? stopButton : reloadButton)
    }

    // MARK: - Alert Actions

    private func showPanel(_ panel: Panel) -> Alert {
        switch panel.type {
        case .alert(let handler):
            return Alert(title: Text(panel.message), dismissButton: .default(Text("OK")) { handler() })
        case .confirm(let handler):
            return Alert(title: Text(panel.message), primaryButton: .default(Text("OK")) { handler(true) }, secondaryButton: .cancel(Text("Cancel")) { handler(true) })
        }
    }

    private func showInputTextPanel(_ panel: InputTextPanel?) {
        guard let panel = panel else {
            return
        }

        let alertController = UIAlertController(title: panel.message, message: nil, preferredStyle: .alert)

        panel.items.forEach { item in
            alertController.addTextField { (textField) in
                textField.placeholder = item.placeholder
                textField.isSecureTextEntry = item.isSecure
            }
        }

        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
            let values = alertController.textFields?.map { $0.text ?? "" }
            panel.handler(values)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
            panel.handler(nil)
        }))

        mostFrontViewController().present(alertController, animated: true, completion: nil)
    }

}
