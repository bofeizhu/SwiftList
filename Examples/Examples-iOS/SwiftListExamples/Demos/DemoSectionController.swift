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
    private var object: DemoItem?
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.sectionController(
            self,
            dequeueReusableCellOfClass: LabelCell.self,
            at: index) as? LabelCell
        else {
            fatalError()
        }
        cell.text = object?.name
        return cell
    }
    
    override func didUpdate(to object: AnyListDiffable) {
        self.object = object.base as? DemoItem
    }
}
