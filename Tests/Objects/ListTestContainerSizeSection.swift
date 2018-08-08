//
//  ListTestContainerSizeSection.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 8/8/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

final class ListTestContainerSizeSection: ListSectionController {
    var size: CGSize
    var items = 0
    var wasSelected: Bool = false
    var cellClasses: [AnyClass] {
        return [UICollectionViewCell.self]
    }
    
    override var numberOfItems: Int {
        return items
    }
    
    override init() {
        size = CGSize(width: 100, height: 10)
        super.init()
        
        inset = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    override func sizeForItem(at index: Int) -> CGSize? {
        return size
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell? {
        return collectionContext?.sectionController(
            self,
            dequeueReusableCellOfClass: UICollectionViewCell.self,
            at: index)
    }
    
    override func didUpdate(to object: AnyListDiffable) {
        if let count = object.base as? Int {
            items = count
        }
    }
    
    override func didSelectItem(at index: Int) {
        wasSelected = true
    }
}
