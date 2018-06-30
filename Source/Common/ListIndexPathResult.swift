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
class ListIndexPathResult {
    /**
     The index paths inserted into the new collection.
     */
    let inserts: [IndexPath]
    
    /**
     The index paths deleted from the old collection.
     */
    let deletes: [IndexPath]
    
    /**
     The index paths in the old collection that need updated.
     */
    let updates: [IndexPath]
    
    /**
     The moves from an index path in the old collection to an index path in the new collection.
     */
    let moves: [ListMoveIndexPath]
    
    /**
     A Read-only boolean that indicates whether the result has any changes or not.
     true if the result has changes, false otherwise.
     */
    var hasChanges: Bool {
        return changeCount > 0
    }
    
    var description: String {
        return "<\(type(of: self)); \(inserts.count) inserts; \(deletes.count) deletes; \(updates.count) updates; \(moves.count) moves>"
    }
    
    private var changeCount: Int {
        return inserts.count + deletes.count + updates.count + moves.count
    }
    private var oldIndexPathDict: [AnyListDiffable: IndexPath]
    private var newIndexPathDict: [AnyListDiffable: IndexPath]
    
    init(inserts: [IndexPath], deletes: [IndexPath], updates: [IndexPath],
         moves: [ListMoveIndexPath],
         oldIndexPathDict: [AnyListDiffable: IndexPath],
         newIndexPathDict: [AnyListDiffable: IndexPath]) {
        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves
        self.oldIndexPathDict = oldIndexPathDict
        self.newIndexPathDict = newIndexPathDict
    }
    
    /**
     Returns the index path of the object with the specified identifier *before* the diff.
     - Parameters:
        - identifier: The diff identifier of the object.
     
     - Returns: The optional index path of the object before the diff.
         - See: `ListDiffable.diffIdentifier`.
     */
    func oldIndexPathForIdentifier(identifier: AnyListDiffable) -> IndexPath? {
        return oldIndexPathDict[identifier]
    }
    
    /**
     Returns the index path of the object with the specified identifier *after* the diff.
     - Parameters:
        - identifier: The diff identifier of the object.
     
     - Returns: The optional index path of the object after the diff.
        - See: `ListDiffable.diffIdentifier`.
     */
    func newIndexPathForIdentifier(identifier: AnyListDiffable) -> IndexPath? {
        return newIndexPathDict[identifier]
    }
    
    /**
     Creates a new result object with operations safe for use in `UITableView` and `UICollectionView` batch updates.
     */
    func resultForBatchUpdates() -> ListIndexPathResult {
        var deletes = Set(self.deletes)
        var inserts = Set(self.inserts)
        var filteredUpdates = Set(self.updates)
        var filteredMoves = self.moves
        
        // convert move+update to delete+insert, respecting the from/to of the move
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
}
