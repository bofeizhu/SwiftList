//
//  ListIndexSetResult.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 A result object returned when diffing with indexes.
 */
public class ListIndexSetResult {
    /**
     The indexes inserted into the new collection.
     */
    public let inserts: IndexSet
    
    /**
     The indexes deleted from the old collection.
     */
    public let deletes: IndexSet
    
    /**
     The indexes in the old collection that need updated.
     */
    public let updates: IndexSet
    
    /**
     The moves from an index in the old collection to an index in the new collection.
     */
    public let moves: [ListMoveIndex]
    
    /**
     A Read-only boolean that indicates whether the result has any changes or not.
     true if the result has changes, false otherwise.
     */
    public var hasChanges: Bool {
        return changeCount > 0
    }
    
    /**
     Returns the index of the object with the specified identifier *before* the diff.
     - Parameters:
        - identifier: The diff identifier of the object.
     
     - Returns: The optional index of the object before the diff.
        - See: `ListDiffable.diffIdentifier`.
     */
    public func oldIndexForIdentifier(identifier: AnyListDiffable) -> Int? {
        return oldIndexDict[identifier]
    }
    
    /**
     Returns the index of the object with the specified identifier *after* the diff.
     - Parameters:
        - identifier: The diff identifier of the object.
     
     - Returns: The optional index of the object after the diff.
        - See: `ListDiffable.diffIdentifier`.
     */
    public func newIndexForIdentifier(identifier: AnyListDiffable) -> Int? {
        return newIndexDict[identifier]
    }
    
    /**
     Creates a new result object with operations safe for use in `UITableView` and `UICollectionView` batch updates.
     */
    public func resultForBatchUpdates() -> ListIndexSetResult {
        var deletes = self.deletes
        var inserts = self.inserts
        var filteredUpdates = self.updates
        var filteredMoves = self.moves
        
        // convert all update+move to delete+insert
        let moveCount = moves.count;
        for i in stride(from: moveCount, through: 0, by: -1) {
            let move = moves[i]
            if filteredUpdates.contains(move.from) {
                filteredMoves.remove(at: i)
                filteredUpdates.remove(move.from)
                deletes.insert(move.from)
                inserts.insert(move.to)
            }
        }
        
        // iterate all new identifiers. if its index is updated, delete from the old index and insert the new index
        for (key, indexPath) in oldIndexDict {
            if filteredUpdates.contains(indexPath) {
                deletes.insert(indexPath)
                // TODO: should add assert here?
                if let newIndexPath = newIndexDict[key] {
                    inserts.insert(newIndexPath)
                }
            }
        }
        
        return ListIndexSetResult(inserts: inserts, deletes: deletes, updates: IndexSet(),
                                   moves: filteredMoves,
                                   oldIndexDict: oldIndexDict,
                                   newIndexDict: newIndexDict)
    }
    
    var description: String {
        return "<\(type(of: self)); \(inserts.count) inserts; \(deletes.count) deletes; \(updates.count) updates; \(moves.count) moves>"
    }
    
    var changeCount: Int {
        return inserts.count + deletes.count + updates.count + moves.count
    }
    
    private var oldIndexDict: [AnyListDiffable: Int]
    private var newIndexDict: [AnyListDiffable: Int]
    
    init(inserts: IndexSet, deletes: IndexSet, updates: IndexSet,
         moves: [ListMoveIndex],
         oldIndexDict: [AnyListDiffable: Int],
         newIndexDict: [AnyListDiffable: Int]) {
        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves
        self.oldIndexDict = oldIndexDict
        self.newIndexDict = newIndexDict
    }
    
}
