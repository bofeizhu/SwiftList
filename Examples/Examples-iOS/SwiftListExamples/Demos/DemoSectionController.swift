//
//  DemoSectionController.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import UIKit
import SwiftList

struct DemoItem {
    let name: String
    let controllerClass: UIViewController.Type
    let controllerIdentifier: String?
    
    init(
        name: String,
        controllerClass: UIViewController.Type,
        controllerIdentifier: String? = nil
        ) {
        self.name = name
        self.controllerClass = controllerClass
        self.controllerIdentifier = controllerIdentifier
    }
}

extension DemoItem: ListDiffable {
    var diffIdentifier: AnyHashable {
        return name
    }
    
    static func == (lhs: DemoItem, rhs: DemoItem) -> Bool {
        return lhs.name == rhs.name &&
            lhs.controllerClass == rhs.controllerClass &&
            lhs.controllerIdentifier == rhs.controllerIdentifier
    }
}

final class DemoSectionController: ListSectionController {
    
}
