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
    
    func testWhenSettingCollectionViewThenSettingDataSourceThatViewControllerIsSet() {
        dataSource.objects = [0, 1, 2].typeErased()
        let controller = UIViewController()
        let adapter = ListAdapter(updater: ListReloadDataUpdater(), viewController: controller)
        adapter.collectionView = self.collectionView
        adapter.dataSource = self.dataSource
        let sectionController = adapter.sectionController(for: AnyListDiffable(1))
        XCTAssertEqual(controller, sectionController?.viewController)
    }
    
    func testWhenSettingCollectionViewThenSettingDataSourceThatCellExists() {
        dataSource.objects = [1].typeErased()
        let adapter = ListAdapter(updater: ListReloadDataUpdater(), viewController: nil)
        adapter.collectionView = self.collectionView
        adapter.dataSource = self.dataSource
        collectionView.layoutIfNeeded()
        XCTAssertNotNil(collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
    }
    
    func testWhenSettingDataSourceThenSettingCollectionViewThatCellExists() {
        dataSource.objects = [1].typeErased()
        let adapter = ListAdapter(updater: ListReloadDataUpdater(), viewController: nil)
        adapter.dataSource = self.dataSource
        adapter.collectionView = self.collectionView
        collectionView.layoutIfNeeded()
        XCTAssertNotNil(collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
    }
    
    func testWhenChangingCollectionViewsThatCellsExist() {
        dataSource.objects = [1].typeErased()
        let updater = ListAdapterUpdater()
        let adapter = ListAdapter(updater: updater, viewController: nil)
        adapter.dataSource = self.dataSource
        adapter.collectionView = self.collectionView
        collectionView.layoutIfNeeded()
        XCTAssertNotNil(collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
        
        let otherCollectionView = UICollectionView(
            frame: collectionView.frame,
            collectionViewLayout: collectionView.collectionViewLayout)
        adapter.collectionView = otherCollectionView
        otherCollectionView.layoutIfNeeded()
        XCTAssertNotNil(collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
    }
    
    func testWhenChangingToCollectionViewInUseByOtherAdapterThatCollectionViewDelegateIsUpdated() {
        let dataSource1 = ListTestAdapterDataSource()
        dataSource1.objects = [1].typeErased()
        let updater1 = ListAdapterUpdater()
        let adapter1 = ListAdapter(updater: updater1, viewController: nil)
        adapter1.dataSource = dataSource1
        
        let dataSource2 = ListTestAdapterDataSource()
        dataSource2.objects = [1].typeErased()
        let updater2 = ListAdapterUpdater()
        let adapter2 = ListAdapter(updater: updater2, viewController: nil)
        adapter1.dataSource = dataSource2
        
        // associate collection view with adapter1
        adapter1.collectionView = collectionView
        XCTAssertEqual(collectionView.dataSource as! ListAdapter, adapter1)
        
        // associate collection view with adapter2
        adapter2.collectionView = self.collectionView
        XCTAssertEqual(collectionView.dataSource as! ListAdapter, adapter2)
        
        // associate collection view with adapter1
        adapter1.collectionView = self.collectionView
        XCTAssertEqual(collectionView.dataSource as! ListAdapter, adapter1)
    }
}
