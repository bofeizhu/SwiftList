//
//  ListTestSection.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListTestSection: ListSectionController {
    var size: CGSize
    var items = 0
    var wasSelected: Bool = false
    var wasDeselected: Bool = false
    var wasHighlighted: Bool = false
    var wasUnhighlighted: Bool = false
    var cellClasses: [AnyClass] {
        return [UICollectionViewCell.self]
    }
    
    override var numberOfItems: Int {
        return items
    }
    
    override init() {
        size = CGSize(width: 100, height: 10)
        super.init()
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
    
    override func didDeselectItem(at index: Int) {
        wasDeselected = true
    }
    
    override func didHighlightItem(at index: Int) {
        wasHighlighted = true
    }
    
    override func didUnhighlightItem(at index: Int) {
        wasUnhighlighted = true
    }
}
