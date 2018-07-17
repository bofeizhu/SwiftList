//
//  ListIndexSetResult.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// A result object returned when diffing with indexes.
public class ListIndexSetResult {

    /// The indexes inserted into the new collection.
    public let inserts: IndexSet

    /// The indexes deleted from the old collection.
    public let deletes: IndexSet

    /// The indexes in the old collection that need updated.
    public let updates: IndexSet

    /// The moves from an index in the old collection to an index in the new collection.
    public let moves: [ListMoveIndex]
    
    /// A Read-only boolean that indicates whether the result has any changes or not.
    // `true` if the result has changes, `false` otherwise.
    public var hasChanges: Bool {
        return changeCount > 0
    }
    
    /// Returns the index of the object with the specified diffIdentifier *before* the diff.
    ///
    /// - Parameter diffIdentifier: The diffIdentifier of the object.
    /// - Returns: The optional index of the object before the diff.
    public func oldIndexFor(diffIdentifier: AnyHashable?) -> Int? {
        guard let d = diffIdentifier else {
            return nil
        }
        
        return oldIndexDict[d]
    }
    
    /// Returns the index of the object with the specified diffIdentifier *after* the diff.
    ///
    /// - Parameter diffIdentifier: The diffIdentifier of the object.
    /// - Returns: The optional index of the object after the diff.
    public func newIndexFor(diffIdentifier: AnyHashable?) -> Int? {
        guard let d = diffIdentifier else {
            return nil
        }
        
        return newIndexDict[d]
    }
    
    /// Creates a new result object with operations safe for use in `UITableView` and
    /// `UICollectionView` batch updates.
    ///
    /// - Returns: A new result object for batch updates.
    public func resultForBatchUpdates() -> ListIndexSetResult {
        var deletes = self.deletes
        var inserts = self.inserts
        var filteredUpdates = self.updates
        var filteredMoves = self.moves
        
        // convert all update+move to delete+insert
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
        
        // iterate all new identifiers. if its index is updated,
        // delete from the old index and insert the new index
        for (key, index) in oldIndexDict {
            if filteredUpdates.contains(index) {
                deletes.insert(index)
                // TODO: should add assert here?
                if let newIndex = newIndexDict[key] {
                    inserts.insert(newIndex)
                }
            }
        }
        
        return ListIndexSetResult(
            inserts: inserts,
            deletes: deletes,
            updates: IndexSet(),
            moves: filteredMoves,
            oldIndexDict: oldIndexDict,
            newIndexDict: newIndexDict)
    }
    
    // MARK: Private API
    var changeCount: Int {
        return inserts.count + deletes.count + updates.count + moves.count
    }
    
    init(
        inserts: IndexSet,
        deletes: IndexSet,
        updates: IndexSet,
        moves: [ListMoveIndex],
        oldIndexDict: [AnyHashable: Int],
        newIndexDict: [AnyHashable: Int]
    ) {
        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves
        self.oldIndexDict = oldIndexDict
        self.newIndexDict = newIndexDict
    }
    
    private var oldIndexDict: [AnyHashable: Int]
    private var newIndexDict: [AnyHashable: Int]
}

extension ListIndexSetResult: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)); \(inserts.count) inserts; \(deletes.count) deletes;" +
            " \(updates.count) updates; \(moves.count) moves>"
    }
}
