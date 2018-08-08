//
//  ListAdapterTests.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

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
            kind: "UICollectionElementKindSectionFooter",
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
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionFooter"]
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
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionFooter"]
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
    
    func testWhenScrollViewDelegateSetThatDelegateReceivesEvents() {
        let scrollViewDelegate = ListTestScrollViewDelegate()
        scrollViewDelegate.scrollViewDidScrollExpectation = XCTestExpectation()
        adapter.scrollViewDelegate = scrollViewDelegate
        let expectations = [
            scrollViewDelegate.scrollViewDidScrollExpectation!,
        ]
        adapter.scrollViewDidScroll(collectionView)
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenCollectionViewDelegateSetThatDelegateReceivesEvents() {
        // silence display handler asserts
        dataSource.objects = [1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        collectionViewDelegate.didEndDisplayingCellExpectation = XCTestExpectation()
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            collectionViewDelegate.didEndDisplayingCellExpectation!,
        ]
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)
        adapter.collectionView(collectionView, didEndDisplaying: cell!, forItemAt: indexPath)
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenCollectionViewAndScrollViewDelegateSetThatDelegatesReceiveUniqueEvents() {
        // silence display handler asserts
        dataSource.objects = [1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let scrollViewDelegate = ListTestScrollViewDelegate()
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        scrollViewDelegate.scrollViewDidScrollExpectation = XCTestExpectation()
        collectionViewDelegate.didEndDisplayingCellExpectation = XCTestExpectation()
        collectionViewDelegate.scrollViewDidScrollExpectation = XCTestExpectation()
        collectionViewDelegate.scrollViewDidScrollExpectation?.isInverted = true
        adapter.scrollViewDelegate = scrollViewDelegate
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            scrollViewDelegate.scrollViewDidScrollExpectation!,
            collectionViewDelegate.didEndDisplayingCellExpectation!,
            collectionViewDelegate.scrollViewDidScrollExpectation!,
        ]
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)
        adapter.scrollViewDidScroll(collectionView)
        adapter.collectionView(collectionView, didEndDisplaying: cell!, forItemAt: indexPath)
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenSupplementarySourceSupportsFooterThatHeaderViewsAreNil() {
        dataSource.objects = [1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionFooter"]
        
        let controller = adapter.sectionController(for: AnyListDiffable(1))!
        controller.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = controller
        adapter.performUpdates(animated: false, completion: nil)
        
        XCTAssertNotNil(collectionView.supplementaryView(
            forElementKind: "UICollectionElementKindSectionFooter",
            at: IndexPath(item: 0, section: 0)))
        XCTAssertNil(collectionView.supplementaryView(
            forElementKind: "UICollectionElementKindSectionHeader",
            at: IndexPath(item: 0, section: 0)))
        XCTAssertNil(collectionView.supplementaryView(
            forElementKind: "UICollectionElementKindSectionFooter",
            at: IndexPath(item: 0, section: 1)))
        XCTAssertNil(collectionView.supplementaryView(
            forElementKind: "UICollectionElementKindSectionHeader",
            at: IndexPath(item: 0, section: 1)))
    }
    
    // TODO: - Sync tests L523 - L600
    
    func testWhenAdapterUpdatedTwiceWithThreeSectionsThatSectionsUpdatedFirstLast() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertTrue(self.adapter.sectionController(for: AnyListDiffable(0))!.isFirstSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(1))!.isFirstSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(2))!.isFirstSection)
        
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(0))!.isLastSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(1))!.isLastSection)
        XCTAssertTrue(self.adapter.sectionController(for: AnyListDiffable(2))!.isLastSection)
        
        // update and shift objects to test that first/last flags are also updated
        dataSource.objects = [2, 0, 1].typeErased()
        adapter.performUpdates(animated: false, completion: nil)
        
        XCTAssertTrue(self.adapter.sectionController(for: AnyListDiffable(2))!.isFirstSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(0))!.isFirstSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(1))!.isFirstSection)
        
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(2))!.isLastSection)
        XCTAssertFalse(self.adapter.sectionController(for: AnyListDiffable(0))!.isLastSection)
        XCTAssertTrue(self.adapter.sectionController(for: AnyListDiffable(1))!.isLastSection)
    }
    
    func testWhenAdapterUpdatedWithObjectsOverflowThatVisibleObjectsIsSubsetOfAllObjects() {
        dataSource.objects = [1, 2, 3, 4, 5, 6].typeErased()
        adapter.reloadData(withCompletion: nil)
        collectionView.contentOffset = CGPoint(x: 0, y: 30)
        collectionView.layoutIfNeeded()
        let visibleObjects = adapter.visibleObjects.sorted { ($0.base as! Int) < ($1.base as! Int) }
        let expectedObjects = [3, 4, 5].typeErased()
        XCTAssertEqual(visibleObjects, expectedObjects)
    }
    
    func testWhenAdapterUpdatedThatVisibleCellsForObjectAreFound() {
        dataSource.objects = [2, 10, 5].typeErased()
        adapter.reloadData(withCompletion: nil)
        collectionView.contentOffset = CGPoint(x: 0, y: 80)
        collectionView.layoutIfNeeded()
        let visibleCells10 = adapter.visibleCells(for: AnyListDiffable(10)).sorted {
            let lhsIndexPath = self.collectionView.indexPath(for: $0)!
            let rhsIndexPath = self.collectionView.indexPath(for: $1)!
            if lhsIndexPath.section == rhsIndexPath.section {
                return lhsIndexPath.item < rhsIndexPath.item
            }
            return lhsIndexPath.section < rhsIndexPath.section
        }
        let visibleCells5 = adapter.visibleCells(for: AnyListDiffable(5))
        XCTAssertEqual(visibleCells10.count, 4)
        XCTAssertEqual(visibleCells5.count, 5)
        XCTAssertEqual(collectionView.indexPath(for: visibleCells10[0])?.item, 6)
        XCTAssertEqual(collectionView.indexPath(for: visibleCells10[1])?.item, 7)
        XCTAssertEqual(collectionView.indexPath(for: visibleCells10[2])?.item, 8)
        XCTAssertEqual(collectionView.indexPath(for: visibleCells10[3])?.item, 9)
    }
    
    func testWhenAdapterUpdatedThatVisibleCellsForNilObjectIsEmpty() {
        dataSource.objects = [2, 10, 5].typeErased()
        adapter.reloadData(withCompletion: nil)
        collectionView.contentOffset = CGPoint(x: 0, y: 80)
        collectionView.layoutIfNeeded()
        let visibleCells = adapter.visibleCells(for: AnyListDiffable(3))
        XCTAssertEqual(visibleCells.count, 0)
    }
    
    func testWhenScrollVerticallyToItem() {
        dataSource.objects = [1, 2, 3, 4, 5, 6].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 6)
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(2),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 10))
        adapter.scroll(
            to: AnyListDiffable(3),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 30))
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 110))
        // Content height minus collection view height is 110, can't scroll more than that
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .centeredVertically,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 110))
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 110))
    }
    
    func testWhenScrollVerticallyToItemInASectionWithNoCellsAndNoSupplymentaryView() {
        dataSource.objects = [1, 0, 300].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 3)
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(0),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(300),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 10))
    }
    
    func testWhenScrollVerticallyToItemInASectionWithNoCellsButAHeaderSupplymentaryView() {
        dataSource.objects = [1, 0, 300].typeErased()
        adapter.reloadData(withCompletion: nil)
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionHeader"]
        let controller = adapter.sectionController(for: AnyListDiffable(0))
        controller?.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = controller
        adapter.performUpdates(animated: false, completion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 3)
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(0),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(0),
            withSupplementaryViewOfKinds: ["UICollectionElementKindSectionHeader"],
            in: .vertical,
            at: .top,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 10))
        // Content height minus collection view height is 110, can't scroll more than that
        adapter.scroll(
            to: AnyListDiffable(300),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 20))
    }
    
    func testWhenScrollVerticallyToItemWithPositionning() {
        dataSource.objects = [1, 100, 200].typeErased()
        adapter.reloadData(withCompletion: nil)
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .top,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .centeredVertically,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 10))
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .top,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 10))
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .centeredVertically,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 460))
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 910))
        
        adapter.scroll(
            to: AnyListDiffable(200),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 2910))
    }
    
    func testWhenScrollVerticallyToBottomWithContentInsetsThatFlushWithCollectionViewBounds() {
        dataSource.objects = [100].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        // no insets
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.layoutIfNeeded()
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 900))
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.layoutIfNeeded()
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 900))
        
        collectionView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        collectionView.layoutIfNeeded()
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 900))
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView.layoutIfNeeded()
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 900))
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)
        collectionView.layoutIfNeeded()
        adapter.scroll(
            to: AnyListDiffable(100),
            withSupplementaryViewOfKinds: [],
            in: .vertical,
            at: .bottom,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 900))
    }
    
    func testWhenScrollHorizontallyToItem() {
        let dataSource = ListTestAdapterHorizontalDataSource()
        adapter.dataSource = dataSource
        dataSource.objects = [1, 2, 3, 4, 5, 6].typeErased()
        layout.scrollDirection = .horizontal
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(collectionView.numberOfSections, 6)
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(2),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 10, y: 0))
        adapter.scroll(
            to: AnyListDiffable(3),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 30, y: 0))
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: [],
            animated: false)
        // Content width minus collection view width is 110, can't scroll more than that
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 110, y: 0))
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: .centeredHorizontally,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 110, y: 0))
        adapter.scroll(
            to: AnyListDiffable(6),
            withSupplementaryViewOfKinds: [],
            in: .horizontal,
            at: .right,
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 110, y: 0))
    }
    
    func testWhenScrollToItemThatSupplementarySourceSupportsSingleHeader() {
        dataSource.objects = [1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionHeader"]
        
        let controller = adapter.sectionController(for: AnyListDiffable(1))!
        controller.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = controller
        
        adapter.performUpdates(animated: false, completion: nil)
        
        XCTAssertNotNil(collectionView.supplementaryView(
            forElementKind: "UICollectionElementKindSectionHeader",
            at: IndexPath(item: 0, section: 0)))
        adapter.scroll(
            to: AnyListDiffable(1),
            withSupplementaryViewOfKinds: ["UICollectionElementKindSectionHeader"],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
        adapter.scroll(
            to: AnyListDiffable(2),
            withSupplementaryViewOfKinds: ["UICollectionElementKindSectionHeader"],
            in: .vertical,
            at: [],
            animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 0))
    }
    
    // TODO: test_whenScrollToItem_thatSupplementarySourceSupportsHeaderAndFooter
    
    func testWhenQueryingIndexPathWithOOBSectionControllerThatNilReturned() {
        dataSource.objects = [1, 2, 3].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        let randomSectionController = ListSectionController()
        XCTAssertNil(adapter.indexPath(
            for: randomSectionController,
            at: 0,
            usePreviousIfInUpdateClosure: false))
    }
    
    func testWhenQueryingSectionForObjectThatSectionReturned() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(adapter.section(for: AnyListDiffable(0)), 0)
        XCTAssertEqual(adapter.section(for: AnyListDiffable(1)), 1)
        XCTAssertEqual(adapter.section(for: AnyListDiffable(2)), 2)
        XCTAssertNil(adapter.section(for: AnyListDiffable(3)))
    }
    
    func testWhenQueryingSectionControllerForSectionThatControllerReturned() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        XCTAssertEqual(
            adapter.sectionController(for: AnyListDiffable(0))!,
            adapter.sectionController(forSection: 0)!)
        XCTAssertEqual(
            adapter.sectionController(for: AnyListDiffable(1))!,
            adapter.sectionController(forSection: 1)!)
        XCTAssertEqual(
            adapter.sectionController(for: AnyListDiffable(2))!,
            adapter.sectionController(forSection: 2)!)
    }
    
    func testWhenReloadingDataWithNoDataSourceThatCompletionCalledWithFalse() {
        dataSource.objects = [1].typeErased()
        let adapter = ListAdapter(updater: ListReloadDataUpdater(), viewController: nil)
        adapter.collectionView = collectionView
        var executed = false
        adapter.reloadData { (finished) in
            executed = true
            XCTAssertFalse(finished)
        }
        XCTAssertTrue(executed)
    }
    
    func testWhenReloadingDataWithNoCollectionViewThatCompletionCalledWithFalse() {
        dataSource.objects = [1].typeErased()
        let adapter = ListAdapter(updater: ListReloadDataUpdater(), viewController: nil)
        adapter.dataSource = dataSource
        var executed = false
        adapter.reloadData { (finished) in
            executed = true
            XCTAssertFalse(finished)
        }
        XCTAssertTrue(executed)
    }
    
    // TODO: - testWhenSectionControllerDeletingWithEmptyIndexesThatNoUpdatesHappen
    func testWhenSectionControllerDeletingWithEmptyIndexesThatNoUpdatesHappen() {}
    
    func testWhenSelectingCellThatCollectionViewDelegateReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        collectionViewDelegate.didSelectItemAtExpectation = XCTestExpectation()
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            collectionViewDelegate.didSelectItemAtExpectation!,
        ]
        adapter.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenSelectingCellThatSectionControllerReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        adapter.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        
        let s0 = adapter.sectionController(for: AnyListDiffable(0)) as! ListTestSection
        let s1 = adapter.sectionController(for: AnyListDiffable(1)) as! ListTestSection
        let s2 = adapter.sectionController(for: AnyListDiffable(2)) as! ListTestSection
        
        XCTAssertTrue(s0.wasSelected)
        XCTAssertFalse(s1.wasSelected)
        XCTAssertFalse(s2.wasSelected)
    }
    
    func testWhenDisplayingCellThatCollectionViewDelegateReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        collectionViewDelegate.willDisplayCellExpectation = XCTestExpectation()
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            collectionViewDelegate.willDisplayCellExpectation!,
        ]
        adapter.collectionView(
            collectionView,
            willDisplay: UICollectionViewCell(),
            forItemAt: IndexPath(item: 0, section: 0))
        wait(for: expectations, timeout: 5)
    }
    
    // TODO: - testWhenWillBeginDraggingThatScrollViewDelegateReceivesMethod
    func testWhenWillBeginDraggingThatScrollViewDelegateReceivesMethod() {}
    
    func testWhenReloadingObjectsThatDontExistThatAdapterContinues() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        adapter.reload([1, 3].typeErased())
        XCTAssertEqual(collectionView.numberOfSections, 3)
    }
    
    func testWhenDeselectingThroughContextThatCellDeselected() {
        dataSource.objects = [1, 2, 3].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        XCTAssertTrue(collectionView.cellForItem(at: indexPath)!.isSelected)
        
        let section = adapter.sectionController(for: AnyListDiffable(1))!
        adapter.sectionController(section, deselectItemAt: 0, animated: false)
        XCTAssertFalse(collectionView.cellForItem(at: indexPath)!.isSelected)
    }
    
    func testWhenSelectingThroughContextThatCellSelected() {
        dataSource.objects = [1, 2, 3].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        let indexPath = IndexPath(item: 0, section: 0)
        let section = adapter.sectionController(for: AnyListDiffable(1))!
        adapter.sectionController(section, selectItemAt: 0, animated: false, scrollPosition: .top)
        XCTAssertTrue(collectionView.cellForItem(at: indexPath)!.isSelected)
    }
    
    func testWhenScrollingToIndexWithSectionControllerThatPositionCorrect() {
        dataSource.objects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15].typeErased()
        adapter.reloadData(withCompletion: nil)
        let section = adapter.sectionController(for: AnyListDiffable(8))!
        section.collectionContext?.scroll(to: section, at: 0, scrollPosition: .top, animated: false)
        XCTAssertEqual(collectionView.contentOffset, CGPoint(x: 0, y: 280))
    }
    
    func testWhenHighlightingCellThatCollectionViewDelegateReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        collectionViewDelegate.didHighlightItemAtExpectation = XCTestExpectation()
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            collectionViewDelegate.didHighlightItemAtExpectation!,
        ]
        adapter.collectionView(collectionView, didHighlightItemAt: IndexPath(item: 0, section: 0))
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenHighlightingCellThatSectionControllerReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        adapter.collectionView(collectionView, didHighlightItemAt: IndexPath(item: 0, section: 0))
        
        let s0 = adapter.sectionController(for: AnyListDiffable(0)) as! ListTestSection
        let s1 = adapter.sectionController(for: AnyListDiffable(1)) as! ListTestSection
        let s2 = adapter.sectionController(for: AnyListDiffable(2)) as! ListTestSection
        
        XCTAssertTrue(s0.wasHighlighted)
        XCTAssertFalse(s1.wasHighlighted)
        XCTAssertFalse(s2.wasHighlighted)
    }
    
    func testWhenUnhighlightingCellThatCollectionViewDelegateReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        let collectionViewDelegate = ListTestCollectionViewDelegate()
        collectionViewDelegate.didUnhighlightItemAtExpectation = XCTestExpectation()
        adapter.collectionViewDelegate = collectionViewDelegate
        let expectations = [
            collectionViewDelegate.didUnhighlightItemAtExpectation!,
        ]
        adapter.collectionView(collectionView, didUnhighlightItemAt: IndexPath(item: 0, section: 0))
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenUnlighlightingCellThatSectionControllerReceivesMethod() {
        dataSource.objects = [0, 1, 2].typeErased()
        adapter.reloadData(withCompletion: nil)
        adapter.collectionView(collectionView, didUnhighlightItemAt: IndexPath(item: 0, section: 0))
        
        let s0 = adapter.sectionController(for: AnyListDiffable(0)) as! ListTestSection
        let s1 = adapter.sectionController(for: AnyListDiffable(1)) as! ListTestSection
        let s2 = adapter.sectionController(for: AnyListDiffable(2)) as! ListTestSection
        
        XCTAssertTrue(s0.wasUnhighlighted)
        XCTAssertFalse(s1.wasUnhighlighted)
        XCTAssertFalse(s2.wasUnhighlighted)
    }

    func testWhenDataSourceDoesntHandleObjectThatObjectIsDropped() {
        // ListTestAdapterDataSource does not handle Strings
        dataSource.objects = [AnyListDiffable(1), AnyListDiffable("dogs"), AnyListDiffable(2)]
        adapter.reloadData(withCompletion: nil)
        let expected = [1, 2].typeErased()
        XCTAssertEqual(adapter.objects, expected)
    }
    
    func testWhenSectionEdgeInsetIsNotZero() {
        dataSource.objects = [42].typeErased()
        adapter.reloadData(withCompletion: nil)
        let controller = adapter.sectionController(for: AnyListDiffable(42))!
        XCTAssertEqual(adapter.containerSize(for: controller), CGSize(width: 98, height: 98))
    }
    
    func testWhenSectionControllerReturnsNegativeSizeThatAdapterReturnsZero() {
        dataSource.objects = [1].typeErased()
        adapter.reloadData(withCompletion: nil)
        let section = adapter.sectionController(for: AnyListDiffable(1)) as! ListTestSection
        section.size = CGSize(width: -1, height: -1)
        let size = adapter.sizeForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(size, CGSize.zero)
    }
    
    func testWhenSupplementarySourceReturnsNegativeSizeThatAdapterReturnsZero() {
        dataSource.objects = [1].typeErased()
        adapter.reloadData(withCompletion: nil)
        
        let supplementarySource = ListTestSupplementarySource()
        supplementarySource.collectionContext = adapter
        supplementarySource.supportedElementKinds = ["UICollectionElementKindSectionHeader"]
        supplementarySource.size = CGSize(width: -1, height: -1)
        
        let controller = adapter.sectionController(for: AnyListDiffable(1))!
        controller.supplementaryViewSource = supplementarySource
        supplementarySource.sectionController = controller
        
        let size = adapter.sizeForSupplementaryView(
            ofKind: "UICollectionElementKindSectionHeader",
            at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(size, CGSize.zero)
    }
    
    func testWhenQueryingContainerInsetThatMatchesCollectionView() {
        dataSource.objects = [2].typeErased()
        adapter.reloadData(withCompletion: nil)
        collectionView.contentInset = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        let controller = adapter.sectionController(for: AnyListDiffable(2))!
        let inset = controller.collectionContext!.containerInset
        XCTAssertEqual(inset, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
    }
    
    func testWhenQueryingInsetContainerSizeThatResultIsBoundsInsetByContent() {
        dataSource.objects = [2].typeErased()
        adapter.reloadData(withCompletion: nil)
        collectionView.contentInset = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        let controller = adapter.sectionController(for: AnyListDiffable(2))!
        let size = controller.collectionContext!.insetContainerSize
        XCTAssertEqual(size, CGSize(width: 94, height: 96))
    }
}
