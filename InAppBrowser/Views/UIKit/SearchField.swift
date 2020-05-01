//
//  SearchField.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct SearchField: UIViewRepresentable {

    @State var placeholder: String

    @Binding var value: String

    func makeCoordinator() -> SearchField.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let uiView = UITextField()
        uiView.delegate = context.coordinator
        uiView.font = UIFont.systemFont(ofSize: 17)
        uiView.returnKeyType = .search
        uiView.placeholder = placeholder
        uiView.borderStyle = .roundedRect
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return uiView
    }

    func updateUIView(_ uiView: UITextField, context: Context) {

    }

    // MARK: - Coordinator Classs

    class Coordinator: NSObject, UITextFieldDelegate {

        var view: SearchField

        init(_ view: SearchField) {
            self.view = view
        }

        // MARK: - TextField delegate

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if (textField.text?.count ?? 0) > 0 {
                self.view.value = textField.text ?? ""
                return true
            }
            return false
        }
    }

}
