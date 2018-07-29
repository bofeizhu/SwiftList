//
//  LabelSectionController.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import UIKit
import SwiftList

final class LabelSectionController: ListSectionController {
    private var object: String?
    
    override func sizeForItem(at index: Int) -> CGSize? {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell? {
        guard let cell = collectionContext?.sectionController(
            self,
            dequeueReusableCellOfClass: LabelCell.self,
            at: index) as? LabelCell
        else {
            preconditionFailure()
        }
        cell.text = object
        return cell
    }
    
    override func didUpdate(to object: AnyListDiffable) {
        self.object = String(describing: object.base)
    }
}
