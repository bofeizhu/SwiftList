//
//  ListTestAdapterUpdaterDelegate.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/12/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListTestAdapterUpdaterDelegate: ListAdapterUpdaterDelegate {
    var willPerformBatchUpdatesExpectation: XCTestExpectation?
    var didPerformBatchUpdatesExpectation: XCTestExpectation?
    var willInsertItemsExpectation: XCTestExpectation?
    var willDeleteItemsExpectation: XCTestExpectation?
    var willMoveExpectation: XCTestExpectation?
    var willReloadItemsExpectation: XCTestExpectation?
    var willReloadSectionsExpectation: XCTestExpectation?
    var willReloadDataExpectation: XCTestExpectation?
    var didReloadDataExpectation: XCTestExpectation?
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willPerformBatchUpdatesForCollectionView
        collectView: UICollectionView) {
        willPerformBatchUpdatesExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        didPerformBatchUpdates
        updates: ListBatchUpdateData,
        forCollectionView collectionView: UICollectionView) {
        didPerformBatchUpdatesExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willInsertItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView) {
        willInsertItemsExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willDeleteItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView) {
        willDeleteItemsExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willMoveAt indexPath: IndexPath,
        to newIndexPath: IndexPath,
        forCollectionView collectionView: UICollectionView) {
        willMoveExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView) {
        willReloadItemsExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadSections sections: IndexSet,
        forCollectionView collectionView: UICollectionView) {
        willReloadSectionsExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadDataForCollectionView collectionView: UICollectionView) {
        willReloadDataExpectation!.fulfill()
    }
    
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        didReloadDataForCollectionView collectionView: UICollectionView) {
        didReloadDataExpectation!.fulfill()
    }
    
    
}
