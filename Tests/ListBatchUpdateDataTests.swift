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
        let result = ListBatchUpdateData(insertSections: IndexSet([0, 1]), deleteSections: IndexSet([5]),
                                         moveSections: Set([ListMoveIndex(from: 3, to: 4)]),
                                         insertIndexPaths: [IndexPath(item: 0, section: 0)],
                                         deleteIndexPaths: [IndexPath(item: 1, section: 0)],
                                         moveIndexPaths: [ListMoveIndexPath(from: IndexPath(item: 6, section: 0),
                                                                            to: IndexPath(item: 6, section: 1))])
        XCTAssertEqual(result.insertSections, IndexSet([0, 1]))
        XCTAssertEqual(result.deleteSections, IndexSet([5]))
        XCTAssertEqual(result.moveSections, Set([ListMoveIndex(from: 3, to: 4)]))
        XCTAssertEqual(result.insertIndexPaths, [IndexPath(item: 0, section: 0)])
        XCTAssertEqual(result.deleteIndexPaths, [IndexPath(item: 1, section: 0)])
        XCTAssertEqual(result.moveIndexPaths.count, 1)
        XCTAssertEqual(result.moveIndexPaths.first,
                       ListMoveIndexPath(from: IndexPath(item: 6, section: 0),
                                         to: IndexPath(item: 6, section: 1)))
    }
    
    func testWhenMovingSectionsWithItemDeletesThatResultConvertsConflictsToDeletesAndInserts() {
        let result = ListBatchUpdateData(insertSections: IndexSet(), deleteSections: IndexSet(),
                                         moveSections: Set([ListMoveIndex(from: 2, to: 4)]),
                                         insertIndexPaths: [],
                                         deleteIndexPaths: [IndexPath(item: 2, section: 0),
                                                            IndexPath(item: 3, section: 4)],
                                         moveIndexPaths: [])
        XCTAssertEqual(result.insertSections, IndexSet([4]))
        XCTAssertEqual(result.deleteSections, IndexSet([2]))
        XCTAssertEqual(result.deleteIndexPaths, [IndexPath(item: 3, section: 4)])
        XCTAssertEqual(result.moveSections.count, 0)
    }
}
