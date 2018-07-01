//
//  ListDiffTests.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 6/30/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListDiffTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWhenDiffingEmptyArraysThatResultHasNoChanges() {
        let o = [AnyListDiffable]()
        let n = [AnyListDiffable]()
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertFalse(result.hasChanges)
    }
    
    func testWhenDiffingFromEmptyArrayThatResultHasChanges() {
        let o = [AnyListDiffable]()
        let n = [1]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.inserts, IndexSet(integer: 0))
        XCTAssertEqual(result.changeCount, 1)
    }
    
    func testWhenDiffingToEmptyArrayThatResultHasChanges() {
        let o = [1]
        let n = [AnyListDiffable]()
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.deletes, IndexSet(integer: 0))
        XCTAssertEqual(result.changeCount, 1)
    }
    
    func testWhenSwappingObjectsThatResultHasMoves() {
        let o = [1, 2]
        let n = [2, 1]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [ListMoveIndex(from: 0, to: 1), ListMoveIndex(from: 1, to: 0)]
        let sortedMoves = result.moves.sorted()
        XCTAssertEqual(sortedMoves, expected)
        XCTAssertEqual(result.changeCount, 2)
    }
    
    func testWhenMovingObjectsTogetherThatResultHasMoves() {
        // "trick" is having multiple @3s
        let o = [1, 2, 3, 3, 4]
        let n = [2, 3, 1, 3, 4]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertTrue(result.moves.contains(ListMoveIndex(from: 1, to: 0)))
        XCTAssertTrue(result.moves.contains(ListMoveIndex(from: 0, to: 2)))
    }
    
    func testWhenDiffingWordsFromPaperWithIndexPathsThatDeletesMatchPaper() {
        // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
        let oString = "much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details ."
        let nString = "a mass of latin words falls upon the relevant facts like soft snow , covering up the details ."
        let o = oString.split(separator: " ")
        let n = nString.split(separator: " ")
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0), IndexPath(item: 9, section: 0),
                        IndexPath(item: 11, section: 0), IndexPath(item: 12, section: 0)]
        XCTAssertEqual(result.deletes, expected)
    }
    
    func testWhenDiffingWordsFromPaperWithIndexPathsThatInsertsMatchPaper() {
        // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
        let oString = "much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details ."
        let nString = "a mass of latin words falls upon the relevant facts like soft snow , covering up the details ."
        let o = oString.split(separator: " ")
        let n = nString.split(separator: " ")
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [IndexPath(item: 3, section: 0), IndexPath(item: 11, section: 0)]
        XCTAssertEqual(result.inserts, expected)
    }
    
    func testWhenSwappingObjectsWithIndexPathsThatResultHasMoves() {
        let o = [1, 2, 3, 4]
        let n = [2, 4, 5, 3]
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [ListMoveIndexPath(from: IndexPath(item: 2, section: 0), to: IndexPath(item: 3, section: 0)),
                        ListMoveIndexPath(from: IndexPath(item: 3, section: 0), to: IndexPath(item: 1, section: 0))]
        let sortedMoves = result.moves.sorted()
        XCTAssertEqual(sortedMoves, expected)
    }
    
    
}
