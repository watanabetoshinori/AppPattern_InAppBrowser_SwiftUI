//
//  InAppBrowserBackForwardList.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import WebKit

struct InAppBrowserBackForwardList: View {

    @Environment(\.presentationMode) var presentationMode

    @Binding var webView: WKWebView

    var items = [WKBackForwardListItem]()

    var body: some View {
        // Button

        let doneButton = Button(action: {
            self.presentationMode.wrappedValue.dismiss()

        }) {
            Text("Done")
        }

        // MainView

        return NavigationView {
            List {
                ForEach(items, id: \.url) { element in
                    Button(action: {
                        self.webView.go(to: (element as WKBackForwardListItem))
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text((element as WKBackForwardListItem).title ?? "")
                                .font(.body)
                            Text((element as WKBackForwardListItem).url.host ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Histories"), displayMode: .inline)
            .navigationBarItems(trailing: doneButton)
        }
    }

}
