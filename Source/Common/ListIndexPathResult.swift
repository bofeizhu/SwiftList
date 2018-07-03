//
//  ListIndexPathResult.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 A result object returned when diffing with sections.
 */
public class ListIndexPathResult {
    /**
     The index paths inserted into the new collection.
     */
    public let inserts: [IndexPath]
    
    /**
     The index paths deleted from the old collection.
     */
    public let deletes: [IndexPath]
    
    /**
     The index paths in the old collection that need updated.
     */
    public let updates: [IndexPath]
    
    /**
     The moves from an index path in the old collection to an index path in the new collection.
     */
    public let moves: [ListMoveIndexPath]
    
    /**
     A Read-only boolean that indicates whether the result has any changes or not.
     true if the result has changes, false otherwise.
     */
    public var hasChanges: Bool {
        return changeCount > 0
    }

    /**
     Returns the index path of the object with the specified hashValue *before* the diff.
     - Parameters:
        - hashValue: The hashValue of the object.
     
     - Returns: The optional index path of the object before the diff.
     */
    public func oldIndexPathFor(hashValue: Int) -> IndexPath? {
        return oldIndexPathDict[hashValue]
    }
    
    /**
     Returns the index path of the object with the specified hashValue *after* the diff.
     - Parameters:
        - hashValue: The hashValue of the object.
     
     - Returns: The optional index path of the object after the diff.
     */
    public func newIndexPathFor(hashValue: Int) -> IndexPath? {
        return newIndexPathDict[hashValue]
    }
    
    /**
     Creates a new result object with operations safe for use in `UITableView` and `UICollectionView` batch updates.
     */
    public func resultForBatchUpdates() -> ListIndexPathResult {
        var deletes = Set(self.deletes)
        var inserts = Set(self.inserts)
        var filteredUpdates = Set(self.updates)
        var filteredMoves = self.moves
        
        // convert move+update to delete+insert, respecting the from/to of the move
        let moveCount = moves.count;
        for i in stride(from: moveCount - 1, through: 0, by: -1) {
            let move = moves[i]
            if filteredUpdates.contains(move.from) {
                filteredMoves.remove(at: i)
                filteredUpdates.remove(move.from)
                deletes.insert(move.from)
                inserts.insert(move.to)
            }
        }
        
        // iterate all new identifiers. if its index is updated, delete from the old index and insert the new index
        for (key, indexPath) in oldIndexPathDict {
            if filteredUpdates.contains(indexPath) {
                deletes.insert(indexPath)
                // TODO: should add assert here?
                if let newIndexPath = newIndexPathDict[key] {
                    inserts.insert(newIndexPath)
                }
            }
        }
        
        return ListIndexPathResult(inserts: Array(inserts), deletes: Array(deletes),
                                   updates: [], moves: filteredMoves,
                                   oldIndexPathDict: oldIndexPathDict,
                                   newIndexPathDict: newIndexPathDict)
    }
    
    //MARK: Internal API
    var changeCount: Int {
        return inserts.count + deletes.count + updates.count + moves.count
    }
    
    init(inserts: [IndexPath], deletes: [IndexPath], updates: [IndexPath],
         moves: [ListMoveIndexPath],
         oldIndexPathDict: [Int: IndexPath],
         newIndexPathDict: [Int: IndexPath]) {
        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves
        self.oldIndexPathDict = oldIndexPathDict
        self.newIndexPathDict = newIndexPathDict
    }
    
    //MARK: Private
    private var oldIndexPathDict: [Int: IndexPath]
    private var newIndexPathDict: [Int: IndexPath]
}

extension ListIndexPathResult: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)); \(inserts.count) inserts; \(deletes.count) deletes; \(updates.count) updates; \(moves.count) moves>"
    }
}
