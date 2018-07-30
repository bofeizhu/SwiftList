//
//  ListAdapterUpdaterTests.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/10/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListAdapterUpdaterTests: XCTestCase {
    var window: UIWindow!
    var collectionView: UICollectionView!
    var dataSource: ListTestUICollectionViewDataSource!
    var updater: ListAdapterUpdater!
    var updateClosure: ListObjectTransitionClosure!
    var collectionViewClosure: ListCollectionViewClosure!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: window.frame, collectionViewLayout: layout)
        
        window.addSubview(collectionView)
        
        dataSource = ListTestUICollectionViewDataSource(collectionView: collectionView)
        updater = ListAdapterUpdater()
        updateClosure = { [unowned self] (objects: [AnyListDiffable]) in
            self.dataSource.sections = objects.map { $0.base as! ListTestSectionObject }
        }
        collectionViewClosure = { [unowned self] in
            return self.collectionView
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        collectionView = nil
        dataSource = nil
        updater = nil
        updateClosure = nil
        collectionViewClosure = nil
    }
    
    func testWhenUpdatingWithNilThatUpdaterHasNoChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: nil,
            toObjectsClosure: nil,
            animated: true,
            objectTransitionClosure: updateClosure,
            completion: nil)
        XCTAssertFalse(updater.hasChanges)
    }
    
    func testWhenUpdatingtoObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: nil,
            toObjectsClosure: { [0].typeErased() },
            animated: true,
            objectTransitionClosure: updateClosure,
            completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenUpdatingfromObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: [0].typeErased(),
            toObjectsClosure: nil,
            animated: true,
            objectTransitionClosure: updateClosure,
            completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenUpdatingtoObjectsWithfromObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: [0].typeErased(),
            toObjectsClosure: { [1].typeErased() },
            animated: true,
            objectTransitionClosure: updateClosure,
            completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenCleaningUpStateWithChangesThatUpdaterHasNoChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: nil,
            toObjectsClosure: { [0].typeErased() },
            animated: true,
            objectTransitionClosure: updateClosure,
            completion: nil)
        XCTAssertTrue(updater.hasChanges)
        updater.cleanStateBeforeUpdates()
        XCTAssertFalse(updater.hasChanges)
    }
    
    func testWhenReloadingDataThatCollectionViewUpdates() {
        dataSource.sections = [ListTestSectionObject(objects: [])]
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 1)
        dataSource.sections = []
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 0)
    }
    
    func testWhenInsertingSectionThatCollectionViewUpdates() {
        let from = [ListTestSectionObject(objects: [])]
        let to = {
            [ListTestSectionObject(objects: []), ListTestSectionObject(objects: [])].typeErased()
        }
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 1)
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 2)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenDeletingSectionThatCollectionViewUpdates() {
        let from = [
            ListTestSectionObject(objects: []),
            ListTestSectionObject(objects: []),
        ]
        let to = {
            [ListTestSectionObject(objects: [])].typeErased()
        }
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 2)
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 1)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenInsertingSectionWithItemChangesThatCollectionViewUpdates() {
        let from = [ListTestSectionObject(objects: [0].typeErased())]
        let to = {
            [ListTestSectionObject(objects: [0, 1].typeErased()),
             ListTestSectionObject(objects: [0, 1].typeErased())].typeErased()
        }
        
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 1)
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 2)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 0), 2)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 1), 2)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenInsertingSectionWithDeletedSectionThatCollectionViewUpdates() {
        let from = [
            ListTestSectionObject(objects: [0, 1, 2].typeErased()),
            ListTestSectionObject(objects: []),
        ]
        let to = {
            [ListTestSectionObject(objects: [1, 1].typeErased()),
             ListTestSectionObject(objects: [0].typeErased()),
             ListTestSectionObject(objects: [0, 2, 3].typeErased())].typeErased()
        }
        
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 3)
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 3)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 0), 2)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 1), 1)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 2), 3)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenReloadingSectionsThatCollectionViewUpdates() {
        dataSource.sections = [
            ListTestSectionObject(objects: [0, 1].typeErased()),
            ListTestSectionObject(objects: [0, 1].typeErased()),
        ]
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        XCTAssertEqual(collectionView.numberOfSections, 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 2)
        
        dataSource.sections = [
            ListTestSectionObject(objects: [0, 1, 2].typeErased()),
            ListTestSectionObject(objects: [0, 1].typeErased()),
        ]
        updater.collectionView(collectionView, reloadSections: IndexSet(integer: 0))
        XCTAssertEqual(collectionView.numberOfSections, 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 3)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 2)
    }
    
    func testWhenCollectionViewNeedsLayoutThatPerformBatchUpdateWorks() {
        let from = [
            ListTestSectionObject(objects: []),
            ListTestSectionObject(objects: []),
        ]
        let to = {
            [ListTestSectionObject(objects: [])].typeErased()
        }
        
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        
        // the collection view has been setup with 1 section and now needs layout
        // calling performBatchUpdates: on a collection view needing layout will force layout
        // we need to ensure that our data source is not changed
        // until the update closure is executed
        collectionView.setNeedsLayout()
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: false,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 1)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenUpdatesAreReentrantThatUpdatesExecuteSerially() {
        let from = [ListTestSectionObject(objects: [])]
        let to = {
            [ListTestSectionObject(objects: []),
             ListTestSectionObject(objects: [])].typeErased()
        }
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        
        var completionCounter = 0
        
        let expectation1 = XCTestExpectation()
        let preUpdateClosure = { [unowned self] in
            let anotherTo = {
                [ListTestSectionObject(objects: []),
                 ListTestSectionObject(objects: []),
                 ListTestSectionObject(objects: [])].typeErased()
            }
            self.updater.performUpdateWith(
                collectionViewClosure: self.collectionViewClosure,
                fromObjects: from.typeErased(),
                toObjectsClosure: anotherTo,
                animated: true,
                objectTransitionClosure: self.updateClosure) { (finished) in
                    completionCounter += 1
                    XCTAssertEqual(self.collectionView.numberOfSections, 3)
                    XCTAssertEqual(completionCounter, 2)
                    expectation1.fulfill()
                }
        }
        
        let expectation2 = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: { [unowned self] (toObjects) in
                // executing this closure within the updater is just before
                // `performBatchUpdates` are applied should be able to queue another update here,
                // similar to an update being queued between it beginning
                // and executing the `performBatchUpdates`
                preUpdateClosure()
                self.dataSource.sections = toObjects.map { $0.base as! ListTestSectionObject }
            },
            completion: { [unowned self] (finished) in
                completionCounter += 1
                XCTAssertEqual(self.collectionView.numberOfSections, 2)
                XCTAssertEqual(completionCounter, 1)
                expectation2.fulfill()
            })
        wait(for: [expectation2, expectation1], timeout: 5, enforceOrder: true)
    }
    
    func testWhenQueuingItemUpdatesThatUpdaterHasChanges() {
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: false,
            itemUpdates: {},
            completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenOnlyQueueingItemUpdatesThatUpdateClosureExecutes() {
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: true,
            itemUpdates: {
                // expectation should be triggered. test failure is a timeout
                expectation.fulfill()
            },
            completion: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenQueueingItemUpdatesWithBatchUpdateThatItemUpdateClosureExecutes() {
        var itemUpdateClosureExecuted = false
        var sectionUpdateClosureExecuted = false
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: nil,
            toObjectsClosure: {
                [ListTestSectionObject(objects: [1].typeErased())].typeErased()
            },
            animated: true,
            objectTransitionClosure: { [unowned self] (toObjects) in
                self.dataSource.sections = toObjects.map { $0.base as! ListTestSectionObject }
                sectionUpdateClosureExecuted = true
            },
            completion: nil)
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: true,
            itemUpdates: {
                itemUpdateClosureExecuted = true
            },
            completion: { [unowned self] (finished) in
                // test in the item completion closure that the SECTION operations have been performed
                XCTAssertEqual(self.collectionView.numberOfSections, 1)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 0), 1)
                XCTAssertTrue(itemUpdateClosureExecuted)
                XCTAssertTrue(sectionUpdateClosureExecuted)
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenItemsMoveAndUpdateThatCollectionViewWorks() {
        var from =  [
            ListTestSectionObject(objects: []),
            ListTestSectionObject(objects: []),
            ListTestSectionObject(objects: []),
        ]
        // change the number of items in the section, which a move would be unable to handle and
        // would throw keep the same pointers so that the objects are equal
        from[2].objects = [1].typeErased()
        from[0].objects = [1, 1].typeErased()
        from[1].objects = [1, 1, 1].typeErased()
        
        let to = { [from[2], from[0], from[1]].typeErased() }
        
        dataSource.sections = from
        updater.performReloadDataWith(collectionViewClosure: collectionViewClosure)
        
        // without moves as inserts, we would assert b/c the # of items in each section changes
        updater.movesAsDeletesInserts = true
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: from.typeErased(),
            toObjectsClosure: to,
            animated: true,
            objectTransitionClosure: updateClosure) { [unowned self] (finished) in
                XCTAssertEqual(self.collectionView.numberOfSections, 3)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 0), 1)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 1), 2)
                XCTAssertEqual(self.collectionView.numberOfItems(inSection: 2), 3)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenConvertingReloadsWithoutChangesThatOriginalIndexUsed() {
        let from: [AnyListDiffable] = []
        let to: [AnyListDiffable] = []
        let result = listDiff(oldArray: from, newArray: to, option: .equality)
        var reloads = result.updates
        reloads.insert(2)
        var deletes = result.deletes
        var inserts = result.inserts
        convert(
            reloads: &reloads,
            toDeletes: &deletes,
            andInserts: &inserts,
            withResult: result,
            fromObjects: from)
        XCTAssertEqual(reloads.count, 0)
        XCTAssertEqual(deletes.count, 1)
        XCTAssertEqual(inserts.count, 1)
        XCTAssertTrue(deletes.contains(2))
        XCTAssertTrue(inserts.contains(2))
    }
    
    func testWhenConvertingReloadsWithChangesThatIndexMoves() {
        let from = [1, 2, 3].typeErased()
        let to = [3, 2, 1].typeErased()
        let result = listDiff(oldArray: from, newArray: to, option: .equality)
        var reloads = result.updates
        reloads.insert(2)
        var deletes = result.deletes
        var inserts = result.inserts
        convert(
            reloads: &reloads,
            toDeletes: &deletes,
            andInserts: &inserts,
            withResult: result,
            fromObjects: from)
        XCTAssertEqual(reloads.count, 0)
        XCTAssertEqual(deletes.count, 1)
        XCTAssertEqual(inserts.count, 1)
        XCTAssertTrue(deletes.contains(2))
        XCTAssertTrue(inserts.contains(0))
    }
    
    func testWhenReloadingSectionWhenSectionRemovedThatConvertMethodCorrects() {
        let from = ["a", "b", "c"].typeErased()
        let to = ["a", "c"].typeErased()
        let result = listDiff(oldArray: from, newArray: to, option: .equality)
        var reloads = IndexSet(integer: 1)
        var deletes = IndexSet()
        var inserts = IndexSet()
        convert(
            reloads: &reloads,
            toDeletes: &deletes,
            andInserts: &inserts,
            withResult: result,
            fromObjects: from)
        XCTAssertEqual(reloads.count, 0)
        XCTAssertEqual(deletes.count, 0)
        XCTAssertEqual(inserts.count, 0)
    }
    
    func testWhenCallingReloadDataWithFlowLayoutWithEstimatedSizeThatSectionItemCountsCorrect() {
        let layout = UICollectionViewFlowLayout()
        // setting the estimated size of a layout causes UICollectionView to requery layout attributes during reloadData
        // this becomes out of sync with the data source if the section/item count changes
        layout.estimatedItemSize = CGSize(width: 100, height: 10)
        
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            collectionViewLayout: layout)
        let dataSource = ListTestUICollectionViewDataSource(collectionView: collectionView)
        
        // 2 sections, 1 item in 1st, 4 items in 2nd
        dataSource.sections = [
            ListTestSectionObject(objects: [1].typeErased()),
            ListTestSectionObject(objects: [1, 2, 3, 4].typeErased()),
        ]
        XCTAssertEqual(collectionView.numberOfSections, 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 4)
        
        dataSource.sections = [
            ListTestSectionObject(objects: [1].typeErased()),
        ]
        let updater = ListAdapterUpdater()
        updater.performReloadDataWith { collectionView }
        
        XCTAssertEqual(collectionView.numberOfSections, 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 1)
        
        dataSource.sections = [
            ListTestSectionObject(objects: [1].typeErased()),
            ListTestSectionObject(objects: [1, 2, 3, 4].typeErased()),
        ]
        updater.performReloadDataWith { collectionView }
        
        XCTAssertEqual(collectionView.numberOfSections, 2)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 4)
    }
    
    func testWhenCollectionViewNotInWindowAndBackgroundReloadFlagisFalseDiffHappens() {
        updater.allowsBackgroundReloading = false
        collectionView.removeFromSuperview()
        
        let delegate = ListTestAdapterUpdaterDelegate()
        updater.delegate = delegate
        
        delegate.willPerformBatchUpdatesExpectation = XCTestExpectation()
        delegate.didPerformBatchUpdatesExpectation = XCTestExpectation()
        
        let expectation = XCTestExpectation()
        let to = { [ListTestSectionObject(objects: [])].typeErased() }
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: dataSource.sections.typeErased(),
            toObjectsClosure: to,
            animated: false,
            objectTransitionClosure: updateClosure) { (finished) in
                expectation.fulfill()
            }
        let expectations = [
            delegate.willPerformBatchUpdatesExpectation!,
            expectation,
            delegate.didPerformBatchUpdatesExpectation!,
        ]
        wait(for: expectations, timeout: 5, enforceOrder: true)
    }
    
    func testWhenCollectionViewNotInWindowAndBackgroundReloadFlagIsDefaultDiffDoesNotHappen() {
        collectionView.removeFromSuperview()
        
        let delegate = ListTestAdapterUpdaterDelegate()
        updater.delegate = delegate
        
        let willPerformBatchUpdatesExpectation = XCTestExpectation()
        willPerformBatchUpdatesExpectation.isInverted = true
        let didPerformBatchUpdatesExpectation = XCTestExpectation()
        didPerformBatchUpdatesExpectation.isInverted = true
        delegate.willPerformBatchUpdatesExpectation = willPerformBatchUpdatesExpectation
        delegate.didPerformBatchUpdatesExpectation = didPerformBatchUpdatesExpectation
        
        let expectation = XCTestExpectation()
        let to = { [ListTestSectionObject(objects: [])].typeErased() }
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: dataSource.sections.typeErased(),
            toObjectsClosure: to,
            animated: false,
            objectTransitionClosure: updateClosure) { (finished) in
                expectation.fulfill()
        }
        let expectations = [
            delegate.willPerformBatchUpdatesExpectation!,
            expectation,
            delegate.didPerformBatchUpdatesExpectation!,
            ]
        wait(for: expectations, timeout: 5)
    }
    
    func testWhenReloadBatchedWithUpdateThatCompletionClosureStillExecuted() {
        let object = ListTestSectionObject(objects: [0, 1, 2].typeErased())
        dataSource.sections = [object]
        var reloadDataCompletionExecuted = false
        updater.reloadDataWith(
            collectionViewClosure: collectionViewClosure,
            reloadUpdateClosure: {},
            completion: { (finished) in
                reloadDataCompletionExecuted = true
            })
        
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: true,
            itemUpdates: { [unowned self] in
                object.objects = [2, 1, 4, 5].typeErased()
                self.updater.collectionView(
                    self.collectionView,
                    insertItemsAt: [IndexPath(item: 2, section: 0), IndexPath(item: 3, section: 0)])
                self.updater.collectionView(
                    self.collectionView,
                    deleteItemsAt: [IndexPath(item: 0, section: 0)])
                self.updater.collectionView(
                    self.collectionView,
                    moveItemAt: IndexPath(item: 2, section: 0),
                    to: IndexPath(item: 0, section: 0))
            }, completion: { (finished) in
                XCTAssertTrue(reloadDataCompletionExecuted)
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 5)
    }
    
    func testWhenNotInViewHierarchyThatUpdatesStillExecuteClosures() {
        collectionView.removeFromSuperview()
        
        let object = ListTestSectionObject(objects: [0, 1, 2].typeErased())
        dataSource.sections = [object]
        
        var objectTransitionClosureExecuted = false
        var completionClosureExecuted = false
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: dataSource.sections.typeErased(),
            toObjectsClosure: { [unowned self] in
                self.dataSource.sections.typeErased()
            },
            animated: true,
            objectTransitionClosure: { (toObjects) in
                objectTransitionClosureExecuted = true
            }, completion: { (finished) in
                completionClosureExecuted = true
            })
        let expectation = XCTestExpectation()
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: true,
            itemUpdates: { [unowned self] in
                object.objects = [2, 1, 4, 5].typeErased()
                self.updater.collectionView(
                    self.collectionView,
                    insertItemsAt: [IndexPath(item: 2, section: 0), IndexPath(item: 3, section: 0)])
                self.updater.collectionView(
                    self.collectionView,
                    deleteItemsAt: [IndexPath(item: 0, section: 0)])
                self.updater.collectionView(
                    self.collectionView,
                    moveItemAt: IndexPath(item: 2, section: 0),
                    to: IndexPath(item: 0, section: 0))
            }, completion: { (finished) in
                XCTAssertTrue(objectTransitionClosureExecuted)
                XCTAssertTrue(completionClosureExecuted)
                expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
    }
}
