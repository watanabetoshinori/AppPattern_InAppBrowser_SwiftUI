//
//  InputTextPanel.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 2020/05/01.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

struct InputTextPanel: Identifiable {

    var id = UUID().uuidString

    let message: String

    let items: [InputeTextItem]

    let handler: ([String]?) -> Void

}
