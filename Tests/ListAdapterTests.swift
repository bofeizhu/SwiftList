//
//  ListAdapterTests.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListAdapterTests: ListTestCase {
    override func setUp() {
        dataSource = ListTestAdapterDataSource()
        updater = ListReloadDataUpdater()
        
        super.setUp()
        
        // test case doesn't use setup(with) for more control over update events
        adapter.collectionView = collectionView
        adapter.dataSource = dataSource
    }
    
    func testWhenAdapterNotUpdatedWithDataSourceUpdatedThatAdapterHasNoSectionControllers() {
        dataSource.objects = [0, 1, 2].typeErased()
        XCTAssertNil(adapter.sectionController(for: AnyListDiffable(0)))
        XCTAssertNil(adapter.sectionController(for: AnyListDiffable(1)))
        XCTAssertNil(adapter.sectionController(for: AnyListDiffable(2)))
    }
}
