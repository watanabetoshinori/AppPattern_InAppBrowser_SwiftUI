//
//  ContentView.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Image("URL")
                .frame(width: 150, height: 150)

            SearchField(placeholder: "Search Web", value: self.$viewModel.searchString)
                .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.top, 40)
        .sheet(isPresented: self.$viewModel.showBrowser) {
            NavigationView {
                InAppBrowser(url: self.viewModel.url!)
            }
        }
   }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
