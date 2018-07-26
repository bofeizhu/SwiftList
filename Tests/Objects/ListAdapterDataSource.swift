//
//  ListAdapterDataSource.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListTestAdapterDataSource: ListTestCaseDataSource {
    var objects: [AnyListDiffable] = []
    var backgroundView: UIView = UIView()
    
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable] {
        return objects
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable
    ) -> ListSectionController {
        return ListTestSection()
    }
    
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView? {
        return backgroundView
    }
    
    
}
