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
    
    func testWhenAdapterUpdatedThatAdapterHasSectionControllers() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(0)))
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(1)))
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(2)))
    }
    
    func testWhenAdapterReloadedThatAdapterHasSectionControllers() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(0)))
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(1)))
        XCTAssertNotNil(adapter.sectionController(for: AnyListDiffable(2)))
    }
    
    func testWhenAdapterUpdatedThatSectionControllerHasSection() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let sectionController = adapter.sectionController(for: AnyListDiffable(1))
        XCTAssertEqual(adapter.section(for: sectionController!)!, 1)
    }
    
    func testWhenAdapterUpdatedWithUnknownItemThatSectionControllerHasNoSection() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let randomSectionController = ListTestSection()
        XCTAssertNil(adapter.section(for: randomSectionController))
    }
    
    func testWhenQueryingAdapterWithUnknownItemThatSectionControllerIsNil() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        XCTAssertNil(adapter.section(for: AnyListDiffable(3)))
    }
    
    func testWhenAdapterUpdatedThatSectionControllerHasCorrectObject() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let sectionController = adapter.sectionController(for: AnyListDiffable(1))
        XCTAssertEqual(adapter.object(for: sectionController!)!, AnyListDiffable(1))
    }
    
    func testWhenQueryingAdapterWithUnknownItemThatObjectForSectionControllerIsNil() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let randomSectionController = ListTestSection()
        XCTAssertNil(adapter.object(for: randomSectionController))
    }
    
    func testWhenQueryingIndexPathsWithSectionControllerThatPathsAreEqual() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let second = adapter.sectionController(for: AnyListDiffable(1))
        let paths = adapter.indexPaths(
            from: second!,
            at: IndexSet(integersIn: 2..<6),
            usePreviousIfInUpdateClosure: false)
        let expected = [
            IndexPath(item: 2, section: 1),
            IndexPath(item: 3, section: 1),
            IndexPath(item: 4, section: 1),
            IndexPath(item: 5, section: 1),
        ]
        XCTAssertEqual(paths, expected)
    }
    
    func testWhenDataSourceChangesThatBackgroundViewVisibilityChanges() {
        self.dataSource.objects = [1].typeErased()
        let background = UIView()
        let dataSource = self.dataSource as? ListTestAdapterDataSource
        dataSource?.backgroundView = background
        var executed = false
        adapter.reloadData { [weak self] (_) in
            XCTAssertTrue((self?.adapter.collectionView?.backgroundView?.isHidden)!)
            XCTAssertEqual(background, self?.adapter.collectionView?.backgroundView)
            self?.dataSource.objects = []
            self?.adapter.reloadData(withCompletion: { (_) in
                XCTAssertFalse((self?.adapter.collectionView?.backgroundView?.isHidden)!)
                XCTAssertEqual(background, self?.adapter.collectionView?.backgroundView)
                executed = true
            })
        }
        XCTAssertTrue(executed)
    }
    
    func testWhenReloadingDataThatNewSectionControllersAreCreated() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let old = adapter.sectionController(for: AnyListDiffable(1))
        adapter.reloadData(withCompletion: nil)
        let new = adapter.sectionController(for: AnyListDiffable(1))
        XCTAssertNotEqual(old!, new!)
    }
    
    
}
