//
//  ListLog.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import os.log

func listLogDebug(_ message: String) {
    // TODO: replace `OSLog.default`
    os_log("%@", log: OSLog.default, type: .debug, message)
}
