//
//  WebViewSettings.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class InAppBrowserSettings: NSObject {

    enum DebugTool {
        case none
        case eruda

        var javascript: String {
            switch self {
            case .eruda:
                return "(function () { var script = document.createElement('script'); script.src=\"//cdn.jsdelivr.net/npm/eruda\"; document.body.appendChild(script); script.onload = function () { eruda.init() } })()"
            default:
                return ""
            }
        }
    }

    var debugTool: DebugTool = .eruda

    // MARK: - Initializing a Singleton

    static let shared = InAppBrowserSettings()

    override private init() {

    }

}
