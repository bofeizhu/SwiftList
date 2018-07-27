//
//  ListTestSupplementarySource.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/27/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListTestSupplementarySource: ListSupplementaryViewSource {
    var dequeueFromNib = false
    var size = CGSize(width: 100, height: 10)
    var supportedElementKinds: [String] = []
    weak var collectionContext: ListCollectionContext?
    weak var sectionController: ListSectionController?
    
    func viewForSupplementaryElement(
        ofKind kind: String,
        at index: Int
    ) -> UICollectionReusableView {
        if dequeueFromNib {
            let view = collectionContext!.sectionController(
                sectionController!,
                dequeueReusableSupplementaryViewOfKind: kind,
                nibName: "ListTestNibSupplementaryView",
                bundle: Bundle(for: ListTestSupplementarySource.self),
                at: index) as! ListTestNibSupplementaryView
            view.label?.text = "Foo bar baz"
            return view
        } else {
            return collectionContext!.sectionController(
                sectionController!,
                dequeueReusableSupplementaryViewOfKind: kind,
                viewClass: UICollectionViewCell.self,
                at: index)
        }
    }
    
    func sizeForSupplementaryView(ofKind kind: String, at index: Int) -> CGSize? {
        return size
    }
    
    
}
