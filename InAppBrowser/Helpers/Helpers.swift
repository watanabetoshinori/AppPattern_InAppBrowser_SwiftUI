//
//  Helpers.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import UIKit

func mostFrontViewController() -> UIViewController {
    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first ?? UIApplication.shared.keyWindow!
    var viewController = keyWindow.rootViewController!
    while(viewController.presentedViewController != nil) {
        viewController = viewController.presentedViewController!
    }
    return viewController
}
