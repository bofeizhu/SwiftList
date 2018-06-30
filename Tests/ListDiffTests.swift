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
}
