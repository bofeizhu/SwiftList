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
    
    func testWhenQueryingIndexPathsInsideBatchUpdateBlockThatPathsAreEqual() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.performUpdates(animated: true, completion: nil)
        let second = adapter.sectionController(for: AnyListDiffable(1))!
        var executed = false
        adapter.performBatchUpdates(
            { [weak self] (batchContext) in
                let paths = self!.adapter.indexPaths(
                    from: second,
                    at: IndexSet(2...3),
                    usePreviousIfInUpdateClosure: true)
                let expected = [
                    IndexPath(item: 2, section: 1),
                    IndexPath(item: 3, section: 1),
                ]
                XCTAssertEqual(paths, expected)
                executed = true
            },
            animated: true,
            completion: nil)
        XCTAssertTrue(executed)
    }
    
    func testWhenQueryingReusableIdentifierThatIdentifierEqualsClassName() {
        let identifier = ListAdapter.reusableViewIdentifier(
            viewClass: UICollectionViewCell.self,
            kind: nil,
            givenReuseIdentifier: nil)
        XCTAssertEqual(identifier, "UICollectionViewCell")
    }
    
    func testWhenQueryingReusableIdentifierWithGivenIdentifierTahtIdentifierIsCorrect() {
        let identifier = ListAdapter.reusableViewIdentifier(
            viewClass: UICollectionViewCell.self,
            kind: nil,
            givenReuseIdentifier: "MyCoolID")
        XCTAssertEqual(identifier, "MyCoolIDUICollectionViewCell")
    }
    
    func testWhenQueryingReusableIdentifierThatIdentifierEqualsClassNameAndSupplimentaryKind() {
        let identifier = ListAdapter.reusableViewIdentifier(
            viewClass: UICollectionViewCell.self,
            kind: UICollectionElementKindSectionFooter.self,
            givenReuseIdentifier: nil)
        XCTAssertEqual(identifier, "UICollectionElementKindSectionFooterUICollectionViewCell")
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
    
    func testWhenCellsExtendBeyondBoundsThatVisibleSectionControllersAreLimited() {
        dataSource.objects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 12)
        let visibleSectionControllers = adapter.visibleSectionControllers
        // UIWindow is 100x100, each cell is 100x10 so should have the following section/cell
        // count: 1 + 2 + 3 + 4 = 10 (100 tall)
        XCTAssertEqual(visibleSectionControllers.count, 4)
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(1))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(2))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(3))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(4))!))
    }
    
    func testWhenCellsExtendBeyondBoundsWithExperimentThatVisibleSectionControllersAreLimited() {
        // add experiment
        adapter.experiments.insert(.fasterVisibleSectionController)
        dataSource.objects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 12)
        let visibleSectionControllers = adapter.visibleSectionControllers
        // UIWindow is 100x100, each cell is 100x10 so should have the following section/cell
        // count: 1 + 2 + 3 + 4 = 10 (100 tall)
        XCTAssertEqual(visibleSectionControllers.count, 4)
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(1))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(2))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(3))!))
        XCTAssertTrue(visibleSectionControllers.contains(
            adapter.sectionController(for: AnyListDiffable(4))!))
    }
    
    func testWithEmptySectionPlusFooterThatVisibleSectionControllersAreCorrect() {
        dataSource.objects = [0].typeErased()
        adapter.reloadData(withCompletion: nil)
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.dequeueFromNib = true
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = [UICollectionElementKindSectionFooter]
        let sectionController = adapter.sectionController(for: AnyListDiffable(0))!
        sectionController.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = sectionController
        adapter.performUpdates(animated: false, completion: nil)
        let visibleSectionControllers = adapter.visibleSectionControllers
        
        XCTAssertEqual(visibleSectionControllers.count, 1)
    }
    
    func testWithEmptySectionPlusFooterWithExperimentThatVisibleSectionControllersAreCorrect() {
        // add experiment
        adapter.experiments.insert(.fasterVisibleSectionController)
        dataSource.objects = [0].typeErased()
        adapter.reloadData(withCompletion: nil)
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.dequeueFromNib = true
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = [UICollectionElementKindSectionFooter]
        let sectionController = adapter.sectionController(for: AnyListDiffable(0))!
        sectionController.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = sectionController
        adapter.performUpdates(animated: false, completion: nil)
        let visibleSectionControllers = adapter.visibleSectionControllers
        
        XCTAssertEqual(visibleSectionControllers.count, 1)
    }
    
    func testWhenCellsExtendBeyondBoundsThatVisibleCellsExistForSectionControllers() {
        dataSource.objects = [2, 3, 4, 5, 6].typeErased()
        adapter.reloadData(withCompletion: nil)
        let sectionController2 = adapter.sectionController(for: AnyListDiffable(2))!
        let sectionController3 = adapter.sectionController(for: AnyListDiffable(3))!
        let sectionController4 = adapter.sectionController(for: AnyListDiffable(4))!
        let sectionController5 = adapter.sectionController(for: AnyListDiffable(5))!
        let sectionController6 = adapter.sectionController(for: AnyListDiffable(6))!
        XCTAssertEqual(adapter.visibleCells(for: sectionController2).count, 2)
        XCTAssertEqual(adapter.visibleCells(for: sectionController3).count, 3)
        XCTAssertEqual(adapter.visibleCells(for: sectionController4).count, 4)
        XCTAssertEqual(adapter.visibleCells(for: sectionController5).count, 1)
        XCTAssertEqual(adapter.visibleCells(for: sectionController6).count, 0)
    }
    
    func testWhenCellsExtendBeyondBoundsThatVisibleIndexPathsExistForSectionControllers() {
        dataSource.objects = [2, 3, 4, 5, 6].typeErased()
        adapter.reloadData(withCompletion: nil)
        let sectionController2 = adapter.sectionController(for: AnyListDiffable(2))!
        let sectionController3 = adapter.sectionController(for: AnyListDiffable(3))!
        let sectionController4 = adapter.sectionController(for: AnyListDiffable(4))!
        let sectionController5 = adapter.sectionController(for: AnyListDiffable(5))!
        let sectionController6 = adapter.sectionController(for: AnyListDiffable(6))!
        XCTAssertEqual(adapter.visibleIndexPaths(for: sectionController2).count, 2)
        XCTAssertEqual(adapter.visibleIndexPaths(for: sectionController3).count, 3)
        XCTAssertEqual(adapter.visibleIndexPaths(for: sectionController4).count, 4)
        XCTAssertEqual(adapter.visibleIndexPaths(for: sectionController5).count, 1)
        XCTAssertEqual(adapter.visibleIndexPaths(for: sectionController6).count, 0)
    }
    
    func testWhenDataSourceAddsItemsThatEmptyViewBecomesVisible() {
        dataSource.objects = []
        let background = UIView()
        if let adapterDataSource = dataSource as? ListTestAdapterDataSource {
            adapterDataSource.backgroundView = background
        }
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.backgroundView, background)
        XCTAssertFalse(collectionView.backgroundView!.isHidden)
        dataSource.objects = [2].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertTrue(collectionView.backgroundView!.isHidden)
    }
    
    func testWhenInsertingIntoEmptySectionThatEmptyViewBecomesHidden() {
        dataSource.objects = [0].typeErased()
        let background = UIView()
        if let adapterDataSource = dataSource as? ListTestAdapterDataSource {
            adapterDataSource.backgroundView = background
        }
        adapter.reloadData(withCompletion: nil)
        XCTAssertFalse(collectionView.backgroundView!.isHidden)
        let sectionController = adapter.sectionController(
            for: AnyListDiffable(0)
        ) as! ListTestSection
        sectionController.items = 1
        adapter.sectionController(sectionController, insertItemsAt: IndexSet([0]))
        XCTAssertTrue(collectionView.backgroundView!.isHidden)
    }
    
    func testWhenDeletingAllItemsFromSectionThatEmptyViewBecomesVisible() {
        dataSource.objects = [1].typeErased()
        let background = UIView()
        if let adapterDataSource = dataSource as? ListTestAdapterDataSource {
            adapterDataSource.backgroundView = background
        }
        adapter.reloadData(withCompletion: nil)
        XCTAssertTrue(collectionView.backgroundView!.isHidden)
        let sectionController = adapter.sectionController(
            for: AnyListDiffable(1)
        ) as! ListTestSection
        sectionController.items = 0
        adapter.sectionController(sectionController, deleteItemsAt: IndexSet([0]))
        XCTAssertFalse(collectionView.backgroundView!.isHidden)
    }
    
    func testWhenEmptySectionAddsItemsThatEmptyViewBecomesHidden() {
        dataSource.objects = [0].typeErased()
        let background = UIView()
        if let adapterDataSource = dataSource as? ListTestAdapterDataSource {
            adapterDataSource.backgroundView = background
        }
        adapter.reloadData(withCompletion: nil)
        XCTAssertFalse(collectionView.backgroundView!.isHidden)
        let sectionController = adapter.sectionController(
            for: AnyListDiffable(0)
        ) as! ListTestSection
        sectionController.items = 2
        adapter.reload(sectionController)
        XCTAssertTrue(collectionView.backgroundView!.isHidden)
    }
    
    func testWhenSectionItemsAreDeletedAsBatchThatEmptyViewBecomesVisible() {
        dataSource.objects = [1, 2].typeErased()
        let background = UIView()
        if let adapterDataSource = dataSource as? ListTestAdapterDataSource {
            adapterDataSource.backgroundView = background
        }
        adapter.reloadData(withCompletion: nil)
        XCTAssertTrue(collectionView.backgroundView!.isHidden)
        let first = adapter.sectionController(for: AnyListDiffable(1)) as! ListTestSection
        let second = adapter.sectionController(for: AnyListDiffable(2)) as! ListTestSection
        let expectation = XCTestExpectation()
        adapter.performBatchUpdates(
            { [weak self] (batchContext) in
                guard let strongSelf = self else { return }
                first.items = 0
                strongSelf.adapter.sectionController(first, deleteItemsAt: IndexSet([0]))
                second.items = 0
                strongSelf.adapter.sectionController(second, deleteItemsAt: IndexSet(0...1))
            },
            animated: true,
            completion: { [weak self] (finished) in
                XCTAssertFalse(self!.collectionView.backgroundView!.isHidden)
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 5)
    }
    
    
}
