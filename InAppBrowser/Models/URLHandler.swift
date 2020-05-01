//
//  URLHandler.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

protocol URLHandler {

    func canHandle(_ url: URL) -> Bool

    func handle(_ url: URL, viewController: UIViewController)

}
