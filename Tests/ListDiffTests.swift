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
    
    func testWhenSwappingObjectsWithIndexPathsThatResultHasMoves() {
        let o = [1, 2, 3, 4]
        let n = [2, 4, 5, 3]
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [ListMoveIndexPath(from: IndexPath(item: 2, section: 0), to: IndexPath(item: 3, section: 0)),
                        ListMoveIndexPath(from: IndexPath(item: 3, section: 0), to: IndexPath(item: 1, section: 0))]
        let sortedMoves = result.moves.sorted()
        XCTAssertEqual(sortedMoves, expected)
    }
    
    func testWhenObjectEqualityChangesThatResultHasUpdates() {
        let o = [ListTestObject(key: "0", value: 0),
                 ListTestObject(key: "1", value: 1),
                 ListTestObject(key: "2", value: 2)]
        let n = [ListTestObject(key: "0", value: 0),
                 ListTestObject(key: "1", value: 3),
                 ListTestObject(key: "2", value: 2)]
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = [IndexPath(item: 1, section: 0)]
        XCTAssertEqual(result.updates, expected)
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
    
    func testWhenDiffingWordsFromPaperThatInsertsMatchPaper() {
        // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
        let oString = "much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details ."
        let nString = "a mass of latin words falls upon the relevant facts like soft snow , covering up the details ."
        let o = oString.split(separator: " ")
        let n = nString.split(separator: " ")
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = IndexSet([3, 11])
        XCTAssertEqual(result.inserts, expected)
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
    
    func testWhenDiffingWordsFromPaperThatDeletesMatchPaper() {
        // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
        let oString = "much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details ."
        let nString = "a mass of latin words falls upon the relevant facts like soft snow , covering up the details ."
        let o = oString.split(separator: " ")
        let n = nString.split(separator: " ")
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        let expected = IndexSet([0, 1, 2, 9, 11, 12])
        XCTAssertEqual(result.deletes, expected)
    }
    
    func testWhenDeletingItemsWithInsertsWithMovesThatResultHasInsertsMovesAndDeletes() {
        let o = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        let n = [0, 2, 3, 4, 7, 6, 9, 5, 10]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        let expectedDeletes = IndexSet([1, 8])
        let expectedInserts = IndexSet([6, 8])
        let expectedMoves = [ListMoveIndex(from: 5, to: 7),
                             ListMoveIndex(from: 7, to: 4)]
        let sortedMoves = result.moves.sorted()
        XCTAssertEqual(result.deletes, expectedDeletes)
        XCTAssertEqual(result.inserts, expectedInserts)
        XCTAssertEqual(sortedMoves, expectedMoves)
    }
    
    func testWhenMovingItemsWithEqualityChangesThatResultsHasMovesAndUpdates() {
        let o = [ListTestObject(key: "0", value: 0),
                 ListTestObject(key: "1", value: 1),
                 ListTestObject(key: "2", value: 2)]
        let n = [ListTestObject(key: "2", value: 3),
                 ListTestObject(key: "1", value: 1),
                 ListTestObject(key: "0", value: 0)]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        let expectedUpdates = IndexSet([2])
        let expectedMoves = [ListMoveIndex(from: 0, to: 2),
                             ListMoveIndex(from: 2, to: 0)]
        let sortedMoves = result.moves.sorted()
        XCTAssertEqual(result.updates, expectedUpdates)
        XCTAssertEqual(sortedMoves, expectedMoves)
    }
    
    func testWhenDeletingObjectsWithArrayOfEqualObjectsThatChangeCountMatches() {
        let o = ["dog", "dog", "dog", "dog"]
        let n = ["dog", "dog"]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        // there is a "flaw" in the algorithm that cannot detect bulk ops when they are all the same object
        // confirm that the results are at least correct
        XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 2)
    }
    
    func testWhenInsertingObjectsWithArrayOfEqualObjectsThatChangeCountMatches() {
        let o = ["dog", "dog"]
        let n = ["dog", "dog", "dog", "dog"]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        // there is a "flaw" in the algorithm that cannot detect bulk ops when they are all the same object
        // confirm that the results are at least correct
        XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 4)
    }
    
    func testWhenInsertingObjectWithOldArrayHavingMultiplesThatChangeCountMatches() {
        let o: [AnyListDiffable] = [49, 33, "cat", "cat", 0, 14]
        let n: [AnyListDiffable] = [49, 33, "cat", "cat", "cat", 0, 14]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 7)
    }
    
    func testWhenMovingDuplicateObjectsThatChangeCountMatches() {
        let o: [AnyListDiffable] = [1, 20, 14, "cat", 4, "dog", "cat", "cat", "fish", "fish"]
        let n: [AnyListDiffable] = [1, 28, 14, "cat", "cat", 4, "dog", "fish", "fish"]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, n.count)
    }
    
    func testWhenDiffingDuplicatesAtTailWithDuplicateAtHeadThatResultHasNoChanges() {
        let o: [AnyListDiffable] = ["cat", 1, 2, 3, "cat"]
        let n = o
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertFalse(result.hasChanges)
    }
    
    func testWhenDuplicateObjectsThatMovesAreUnique() {
        let o: [AnyListDiffable] = ["cat", "dog", "dog", "cat", 65]
        let n: [AnyListDiffable] = ["cat", "dog", "dog", "cat", "cat", "fish", 65]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(Set(result.moves).count, result.moves.count)
    }
    
    func testWhenMovingObjectShiftsOthersThatMovesContainRequiredMoves() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [1, 4, 5, 2, 3, 6, 7]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertTrue(result.moves.contains(ListMoveIndex(from: 3, to: 1)))
        XCTAssertTrue(result.moves.contains(ListMoveIndex(from: 1, to: 3)))
    }
    
    func testWhenDiffingThatOldIndexesMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 1), 0)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 2), 1)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 3), 2)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 4), 3)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 5), 4)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 6), 5)
        XCTAssertEqual(result.oldIndexForIdentifier(identifier: 7), 6)
        XCTAssertNil(result.oldIndexForIdentifier(identifier: 8))
        XCTAssertNil(result.oldIndexForIdentifier(identifier: 9))
    }
    
    func testWhenDiffingThatNewIndexesMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 1), 3)
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 2), 0)
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 3), 2)
        XCTAssertNil(result.newIndexForIdentifier(identifier: 4))
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 5), 4)
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 6), 5)
        XCTAssertNil(result.newIndexForIdentifier(identifier: 7))
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 8), 6)
        XCTAssertEqual(result.newIndexForIdentifier(identifier: 9), 1)
    }
    
    func testWhenDiffingThatOldIndexPathsMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiffPaths(fromSection: 0, toSection: 1, oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 1), IndexPath(item: 0, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 2), IndexPath(item: 1, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 3), IndexPath(item: 2, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 4), IndexPath(item: 3, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 5), IndexPath(item: 4, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 6), IndexPath(item: 5, section: 0))
        XCTAssertEqual(result.oldIndexPathForIdentifier(identifier: 7), IndexPath(item: 6, section: 0))
        XCTAssertNil(result.oldIndexPathForIdentifier(identifier: 8))
        XCTAssertNil(result.oldIndexPathForIdentifier(identifier: 9))
    }
    
    func testWhenDiffingThatNewIndexPathsMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiffPaths(fromSection: 0, toSection: 1, oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 1), IndexPath(item: 3, section: 1))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 2), IndexPath(item: 0, section: 1))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 3), IndexPath(item: 2, section: 1))
        XCTAssertNil(result.newIndexPathForIdentifier(identifier: 4))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 5), IndexPath(item: 4, section: 1))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 6), IndexPath(item: 5, section: 1))
        XCTAssertNil(result.newIndexPathForIdentifier(identifier: 7))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 8), IndexPath(item: 6, section: 1))
        XCTAssertEqual(result.newIndexPathForIdentifier(identifier: 9), IndexPath(item: 1, section: 1))
    }
    
    
    //TODO: Tests for `ListDiffObjectIdentifier`
}
