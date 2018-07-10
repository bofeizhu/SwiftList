//
//  ListAdapterUpdaterTests.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/10/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

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
        let layout = UICollectionViewLayout()
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
        updater.performUpdateWith(collectionViewClosure: collectionViewClosure,
                                  fromObjects: nil, toObjectsClosure: nil,
                                  animated: true, objectTransitionClosure: updateClosure,
                                  completion: nil)
        XCTAssertFalse(updater.hasChanges)
    }
    
    func testWhenUpdatingtoObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(collectionViewClosure: collectionViewClosure,
                                  fromObjects: nil, toObjectsClosure: { [0].typeErased() },
                                  animated: true, objectTransitionClosure: updateClosure,
                                  completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenUpdatingfromObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(collectionViewClosure: collectionViewClosure,
                                  fromObjects: [0].typeErased(), toObjectsClosure: nil,
                                  animated: true, objectTransitionClosure: updateClosure,
                                  completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenUpdatingtoObjectsWithfromObjectsThatUpdaterHasChanges() {
        updater.performUpdateWith(collectionViewClosure: collectionViewClosure,
                                  fromObjects: [0].typeErased(),
                                  toObjectsClosure: { [1].typeErased() },
                                  animated: true, objectTransitionClosure: updateClosure,
                                  completion: nil)
        XCTAssertTrue(updater.hasChanges)
    }
    
    func testWhenCleaningUpStateWithChangesThatUpdaterHasNoChanges() {
        updater.performUpdateWith(collectionViewClosure: collectionViewClosure,
                                  fromObjects: nil,
                                  toObjectsClosure: { [0].typeErased() },
                                  animated: true, objectTransitionClosure: updateClosure,
                                  completion: nil)
        XCTAssertTrue(updater.hasChanges)
        updater.cleanStateBeforeUpdates()
        XCTAssertFalse(updater.hasChanges)
    }
    
    
}
