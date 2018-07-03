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
        XCTAssertEqual(result.oldIndexFor(hashValue: 1.hashValue), 0)
        XCTAssertEqual(result.oldIndexFor(hashValue: 2.hashValue), 1)
        XCTAssertEqual(result.oldIndexFor(hashValue: 3.hashValue), 2)
        XCTAssertEqual(result.oldIndexFor(hashValue: 4.hashValue), 3)
        XCTAssertEqual(result.oldIndexFor(hashValue: 5.hashValue), 4)
        XCTAssertEqual(result.oldIndexFor(hashValue: 6.hashValue), 5)
        XCTAssertEqual(result.oldIndexFor(hashValue: 7.hashValue), 6)
        XCTAssertNil(result.oldIndexFor(hashValue: 8.hashValue))
        XCTAssertNil(result.oldIndexFor(hashValue: 9.hashValue))
    }
    
    func testWhenDiffingThatNewIndexesMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.newIndexFor(hashValue: 1.hashValue), 3)
        XCTAssertEqual(result.newIndexFor(hashValue: 2.hashValue), 0)
        XCTAssertEqual(result.newIndexFor(hashValue: 3.hashValue), 2)
        XCTAssertNil(result.newIndexFor(hashValue: 4.hashValue))
        XCTAssertEqual(result.newIndexFor(hashValue: 5.hashValue), 4)
        XCTAssertEqual(result.newIndexFor(hashValue: 6.hashValue), 5)
        XCTAssertNil(result.newIndexFor(hashValue: 7.hashValue))
        XCTAssertEqual(result.newIndexFor(hashValue: 8.hashValue), 6)
        XCTAssertEqual(result.newIndexFor(hashValue: 9.hashValue), 1)
    }
    
    func testWhenDiffingThatOldIndexPathsMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiffPaths(fromSection: 0, toSection: 1, oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 1.hashValue), IndexPath(item: 0, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 2.hashValue), IndexPath(item: 1, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 3.hashValue), IndexPath(item: 2, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 4.hashValue), IndexPath(item: 3, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 5.hashValue), IndexPath(item: 4, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 6.hashValue), IndexPath(item: 5, section: 0))
        XCTAssertEqual(result.oldIndexPathFor(hashValue: 7.hashValue), IndexPath(item: 6, section: 0))
        XCTAssertNil(result.oldIndexPathFor(hashValue: 8.hashValue))
        XCTAssertNil(result.oldIndexPathFor(hashValue: 9.hashValue))
    }
    
    func testWhenDiffingThatNewIndexPathsMatch() {
        let o = [1, 2, 3, 4, 5, 6, 7]
        let n = [2, 9, 3, 1, 5, 6, 8]
        let result = ListDiffPaths(fromSection: 0, toSection: 1, oldArray: o, newArray: n, option: .ListDiffEquality)
        XCTAssertEqual(result.newIndexPathFor(hashValue: 1.hashValue), IndexPath(item: 3, section: 1))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 2.hashValue), IndexPath(item: 0, section: 1))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 3.hashValue), IndexPath(item: 2, section: 1))
        XCTAssertNil(result.newIndexPathFor(hashValue: 4.hashValue))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 5.hashValue), IndexPath(item: 4, section: 1))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 6.hashValue), IndexPath(item: 5, section: 1))
        XCTAssertNil(result.newIndexPathFor(hashValue: 7.hashValue))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 8.hashValue), IndexPath(item: 6, section: 1))
        XCTAssertEqual(result.newIndexPathFor(hashValue: 9.hashValue), IndexPath(item: 1, section: 1))
    }
    
    func testWhenDiffingWithBatchUpdateResultThatIndexesMatch() {
        let o = [ListTestObject(key: 1, value: 1),
                 ListTestObject(key: 2, value: 1),
                 ListTestObject(key: 3, value: 1),
                 ListTestObject(key: 4, value: 1),
                 ListTestObject(key: 5, value: 1),
                 ListTestObject(key: 6, value: 1)]
        let n = [ListTestObject(key: 2, value: 2), // deleted & updated
                 ListTestObject(key: 5, value: 1), // moved
                 ListTestObject(key: 4, value: 1),
                 ListTestObject(key: 7, value: 1), // inserted
                 ListTestObject(key: 6, value: 2), // updated
                 ListTestObject(key: 3, value: 2)] // moved + updated
        let result = ListDiff(oldArray: o, newArray: n, option: .ListDiffEquality).resultForBatchUpdates()
        XCTAssertEqual(result.updates.count, 0)
        let expectedMoves = [ListMoveIndex(from: 4, to: 1)]
        XCTAssertEqual(result.moves, expectedMoves)
        let expectedDeletes = IndexSet([0, 1, 2, 5])
        XCTAssertEqual(result.deletes, expectedDeletes)
        let expectedInserts = IndexSet([0, 3, 4, 5])
        XCTAssertEqual(result.inserts, expectedInserts)
    }
    
    func testwhenDiffingWithBatchUpdateResultThatIndexPathsMatch() {
        let o = [ListTestObject(key: 1, value: 1),
                 ListTestObject(key: 2, value: 1),
                 ListTestObject(key: 3, value: 1),
                 ListTestObject(key: 4, value: 1),
                 ListTestObject(key: 5, value: 1),
                 ListTestObject(key: 6, value: 1)]
        let n = [ListTestObject(key: 2, value: 2), // deleted & updated
            ListTestObject(key: 5, value: 1), // moved
            ListTestObject(key: 4, value: 1),
            ListTestObject(key: 7, value: 1), // inserted
            ListTestObject(key: 6, value: 2), // updated
            ListTestObject(key: 3, value: 2)] // moved + updated
        let result = ListDiffPaths(fromSection: 0, toSection: 1,
                                   oldArray: o, newArray: n,
                                   option: .ListDiffEquality).resultForBatchUpdates()
        XCTAssertEqual(result.updates.count, 0)
        let expectedMoves = [ListMoveIndexPath(from: IndexPath(item: 4, section: 0), to: IndexPath(item: 1, section: 1))]
        XCTAssertEqual(result.moves, expectedMoves)
        let expectedDeletes = [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0),
                               IndexPath(item: 2, section: 0), IndexPath(item: 5, section: 0)]
        XCTAssertEqual(result.deletes.sorted(), expectedDeletes)
        let expectedInserts = [IndexPath(item: 0, section: 1), IndexPath(item: 3, section: 1),
                               IndexPath(item: 4, section: 1), IndexPath(item: 5, section: 1)]
        XCTAssertEqual(result.inserts.sorted(), expectedInserts)
    }
    
    func testWhenDiffingPointersWithObjectCopyThatResultHasUpdate() {
        let o = [ListTestClassObject(key: "0", value: 0),
                 ListTestClassObject(key: "1", value: 1),
                 ListTestClassObject(key: "2", value: 2)]
        let n = [o[0], ListTestClassObject(key: "1", value: 1), o[2]]
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffObjectIdentifier)
        let expected = [IndexPath(item: 1, section: 0)]
        XCTAssertEqual(result.updates, expected)
    }
    
    func testWhenDiffingPointersWithSameObjectsThatResultHasNoChanges() {
        let o = [ListTestClassObject(key: "0", value: 0),
                 ListTestClassObject(key: "1", value: 1),
                 ListTestClassObject(key: "2", value: 2)]
        let n = o
        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: o, newArray: n, option: .ListDiffObjectIdentifier)
        XCTAssertFalse(result.hasChanges)
    }
}
