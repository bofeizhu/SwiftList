//
//  ListTestSingleNibSectionDataSource.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

final class ListTestSingleNibSectionDataSource: ListTestCaseDataSource {
    var objects: [AnyListDiffable] = []
    
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable] {
        return objects
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable
        ) -> ListSectionController {
        let configureClosure = { (item: AnyListDiffable, cell: UICollectionViewCell) in
            let cell = cell as! ListTestNibCell
            let item = item.base as! ListTestObject
            cell.label.text = String(describing: item.value)
        }
        let sizeClosure = { (item: AnyListDiffable, collectionContext: ListCollectionContext?) in
            return CGSize(width: collectionContext!.containerSize.width, height: 44)
        }
        return ListSingleSectionController(
            nibName: "ListTestNibCell",
            bundle: Bundle(for: ListTestSingleNibSectionDataSource.self),
            configureClosure: configureClosure,
            sizeClosure: sizeClosure)
    }
    
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

