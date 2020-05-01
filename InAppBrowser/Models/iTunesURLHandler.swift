//
//  iTunesURLHandler.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import StoreKit

//
// Sample implementation of URLHandler
//
class iTunesURLHandler: NSObject, URLHandler {

    func canHandle(_ url: URL) -> Bool {
        // Valid iTunes URL structure:
        // Domain/Region Code(Optional)/Media Type/Media Name/ID?Prameters

        if url.scheme != "https" || url.host != "apps.apple.com" {
            return false
        }

        let fileName = url.pathComponents.last ?? ""
        if fileName.count <= 2 || fileName.starts(with: "id") == false {
            return false
        }

        if url.pathComponents.count < 4 {
            return false
        }

        var mediaTypeIndex = 2

        // If there is no Region Code in the URL
        // the Media Type has to appear earlier in the URL.
        if url.pathComponents[1].count != 2 {
            mediaTypeIndex -= 1
        }

        return url.pathComponents[mediaTypeIndex] == "app"
    }

    func handle(_ url: URL, viewController: UIViewController) {
        let fileName = url.pathComponents.last ?? ""
        let id = fileName[fileName.index(fileName.startIndex, offsetBy: 2)..<fileName.endIndex]

        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self

        // SKStoreProductViewController#loadProduction does not work in simulator.

        productViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: id]) { (success, error) in
            if success {
                viewController.present(productViewController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
    }

}

extension iTunesURLHandler: SKStoreProductViewControllerDelegate {

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

}
