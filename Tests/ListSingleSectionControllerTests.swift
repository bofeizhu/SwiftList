//
//  ListSingleSectionControllerTests.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListSingleSectionControllerTests: ListTestCase {
    override func setUp() {
        dataSource = ListTestSingleSectionDataSource()
        super.setUp()
    }
    
    func testWhenDisplayingCollectionViewThatSectionsHaveOneItem() {
        setupWith([
            ListTestObject(key: 1, value: "foo"),
            ListTestObject(key: 2, value: "bar"),
            ListTestObject(key: 3, value: "baz"),
        ].typeErased())
        XCTAssertEqual(collectionView.numberOfSections, 3)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 2), 1)
    }
    
    func testWhenDisplayingCollectionViewThatCellsAreConfigured() {
        setupWith([
            ListTestObject(key: 1, value: "foo"),
            ListTestObject(key: 2, value: "bar"),
            ListTestObject(key: 3, value: "baz"),
        ].typeErased())
        let cell0 = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! ListTestCell
        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! ListTestCell
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as! ListTestCell
        XCTAssertEqual(cell0.label.text, "foo")
        XCTAssertEqual(cell1.label.text, "bar")
        XCTAssertEqual(cell2.label.text, "baz")
    }
    
    func testWhenDisplayingCollectionViewThatCellsAreSized() {
        setupWith([
            ListTestObject(key: 1, value: "foo"),
            ListTestObject(key: 2, value: "bar"),
            ListTestObject(key: 3, value: "baz"),
        ].typeErased())
        let cell0 = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! ListTestCell
        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! ListTestCell
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as! ListTestCell
        XCTAssertEqual(cell0.frame.size.height, 44)
        XCTAssertEqual(cell1.frame.size.height, 44)
        XCTAssertEqual(cell2.frame.size.height, 44)
        XCTAssertEqual(cell0.frame.size.width, 100)
        XCTAssertEqual(cell1.frame.size.width, 100)
        XCTAssertEqual(cell2.frame.size.width, 100)
    }
    
    func testWhenItemUpdatedThatCellIsConfigured() {
        setupWith([
            ListTestObject(key: 1, value: "foo"),
            ListTestObject(key: 2, value: "bar"),
            ListTestObject(key: 3, value: "baz"),
        ].typeErased())
        dataSource.objects = [
            ListTestObject(key: 1, value: "foo"),
            ListTestObject(key: 2, value: "qux"),
            ListTestObject(key: 3, value: "baz"),
        ].typeErased()
        let expectation = XCTestExpectation()
        adapter.performUpdates(animated: true) { [weak self] (finished) in
            let cell1 = self!.collectionView.cellForItem(
                at: IndexPath(item: 0, section: 1)) as! ListTestCell
            XCTAssertEqual(cell1.label.text, "qux")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
