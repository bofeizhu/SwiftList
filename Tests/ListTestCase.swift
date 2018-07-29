//
//  ListTestCase.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

protocol ListTestCaseDataSource: ListAdapterDataSource {
    var objects: [AnyListDiffable] { get set }
}

class ListTestCase: XCTestCase {
    // These objects are created for you in setUp()
    var window: UIWindow!
    var adapter: ListAdapter!
    var layout: UICollectionViewFlowLayout!
    
    // Created in setUp() if your subclass has not already created one
    var collectionView: UICollectionView!
    var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    var updater: ListUpdatingDelegate!
    
    // Required objects must be set before super.setUp() in your test subclass
    var dataSource: ListTestCaseDataSource!
    
    // Optional properties that you can set before super.setUp()
    var viewController: UIViewController?
    var workingRangeSize = 0
    
    override func setUp() {
        super.setUp()
        
        assert(dataSource != nil, "Data source must be set in setUp() before testing")
        
        window = UIWindow(frame: frame)
        layout = UICollectionViewFlowLayout()
        collectionView = collectionView ?? UICollectionView(
            frame: frame,
            collectionViewLayout: layout)
        window.addSubview(collectionView)
        updater = updater ?? ListAdapterUpdater()
        adapter = ListAdapter(
            updater: updater,
            viewController: viewController,
            workingRangeSize: workingRangeSize)
    }
    
    override func tearDown() {
        window = nil
        collectionView = nil
        adapter = nil
        dataSource = nil
        updater = nil
        viewController = nil
        workingRangeSize = 0
        
        super.tearDown()
    }
    
    func setupWith(_ objects: [AnyListDiffable]) {
        dataSource.objects = objects
        adapter.collectionView = collectionView
        adapter.dataSource = dataSource
        collectionView.layoutIfNeeded()
    }
}
