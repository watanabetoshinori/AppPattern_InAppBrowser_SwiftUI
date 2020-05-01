//
//  ContentViewModel.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var searchString = ""

    @Published var showBrowser = false

    var url: URL?

    private var cancellables = [AnyCancellable]()

    init() {
        urlPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.url, on: self)
            .store(in: &cancellables)

        urlExistsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.showBrowser, on: self)
            .store(in: &cancellables)
    }

    private var urlPublisher: AnyPublisher<URL?, Never> {
        $searchString
            .removeDuplicates()
            .map { string in
                if string.isEmpty {
                    return nil
                }

                var components = URLComponents(string: "https://www.google.com/search")!
                components.queryItems = [URLQueryItem(name: "q", value: string)]
                return components.url
            }
            .eraseToAnyPublisher()
    }

    private var urlExistsPublisher: AnyPublisher<Bool, Never> {
        Publishers.Map(upstream: urlPublisher) { url in
            url != nil
        }
        .eraseToAnyPublisher()
    }

}
