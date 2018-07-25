//
//  ListBatchUpdateDataTests.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/2/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListBatchUpdateDataTests: XCTestCase {
    func testWhenUpdatesAreCleanThatResultMatches() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet([0, 1]),
            deleteSections: IndexSet([5]),
            moveSections: Set([ListMoveIndex(from: 3, to: 4)]),
            insertIndexPaths: [IndexPath(item: 0, section: 0)],
            deleteIndexPaths: [IndexPath(item: 0, section: 1)],
            moveIndexPaths: [ListMoveIndexPath(from: IndexPath(item: 0, section: 6),
                to: IndexPath(item: 1, section: 6))])
        XCTAssertEqual(result.insertSections, IndexSet([0, 1]))
        XCTAssertEqual(result.deleteSections, IndexSet([5]))
        XCTAssertEqual(result.moveSections, Set([ListMoveIndex(from: 3, to: 4)]))
        XCTAssertEqual(result.insertIndexPaths, [IndexPath(item: 0, section: 0)])
        XCTAssertEqual(result.deleteIndexPaths, [IndexPath(item: 0, section: 1)])
        XCTAssertEqual(result.moveIndexPaths.count, 1)
        XCTAssertEqual(
            result.moveIndexPaths.first,
            ListMoveIndexPath(from: IndexPath(item: 0, section: 6),
                to: IndexPath(item: 1, section: 6)))
    }
    
    func testWhenMovingSectionsWithItemDeletesThatResultConvertsConflictsToDeletesAndInserts() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet(),
            deleteSections: IndexSet(),
            moveSections: Set([ListMoveIndex(from: 2, to: 4)]),
            insertIndexPaths: [],
            deleteIndexPaths: [IndexPath(item: 0, section: 2), IndexPath(item: 4, section: 3)],
            moveIndexPaths: [])
        XCTAssertEqual(result.insertSections, IndexSet([4]))
        XCTAssertEqual(result.deleteSections, IndexSet([2]))
        XCTAssertEqual(result.deleteIndexPaths, [IndexPath(item: 4, section: 3)])
        XCTAssertEqual(result.moveSections.count, 0)
    }
    
    func testWhenMovingSectionsWithItemInsertsThatResultConvertsConflictsToDeletesAndInserts() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet(),
            deleteSections: IndexSet(),
            moveSections: Set([ListMoveIndex(from: 2, to: 4)]),
            insertIndexPaths: [IndexPath(item: 0, section: 4 ), IndexPath(item: 4, section: 3)],
            deleteIndexPaths: [],
            moveIndexPaths: [])
        XCTAssertEqual(result.insertSections, IndexSet([4]))
        XCTAssertEqual(result.deleteSections, IndexSet([2]))
        XCTAssertEqual(result.insertIndexPaths, [IndexPath(item: 4, section: 3)])
        XCTAssertEqual(result.moveSections.count, 0)
    }
    
    func testWhenMovingIndexPathsWithSectionDeletedThatResultDropsTheMove() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet(),
            deleteSections: IndexSet([0]),
            moveSections: Set<ListMoveIndex>(),
            insertIndexPaths: [],
            deleteIndexPaths: [],
            moveIndexPaths: [ListMoveIndexPath(from: IndexPath(item: 0, section: 0),
                to: IndexPath(item: 1, section: 0))])
        XCTAssertEqual(result.moveIndexPaths.count, 0)
        XCTAssertEqual(result.deleteSections, IndexSet([0]))
    }
    
    func testWhenMovingIndexPathsWithSectionMovedThatResultConvertsToDeletesAndInserts() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet(),
            deleteSections: IndexSet(),
            moveSections: Set([ListMoveIndex(from: 0, to: 1)]),
            insertIndexPaths: [],
            deleteIndexPaths: [],
            moveIndexPaths: [ListMoveIndexPath(from: IndexPath(item: 0, section: 0),
                to: IndexPath(item: 1, section: 0))])
        XCTAssertEqual(result.moveIndexPaths.count, 0)
        XCTAssertEqual(result.moveSections.count, 0)
        XCTAssertEqual(result.deleteSections, IndexSet([0]))
        XCTAssertEqual(result.insertSections, IndexSet([1]))
    }
    
    func testWhenMovingSectionsWithMoveFromConflictWithDeleteThatResultDropsTheMove() {
        let result = ListBatchUpdateData(
            insertSections: IndexSet(),
            deleteSections: IndexSet([2]),
            moveSections: Set([ListMoveIndex(from: 2, to: 6), ListMoveIndex(from: 0, to: 2)]),
            insertIndexPaths: [],
            deleteIndexPaths: [],
            moveIndexPaths: [])
        XCTAssertEqual(result.deleteSections.count, 1);
        XCTAssertEqual(result.moveSections.count, 1);
        XCTAssertEqual(result.insertSections.count, 0);
        XCTAssertEqual(result.deleteSections, IndexSet([2]))
        XCTAssertEqual(result.moveSections, Set([ListMoveIndex(from: 0, to: 2)]))
    }
}
