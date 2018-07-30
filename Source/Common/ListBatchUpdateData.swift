//
//  ListBatchUpdateData.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/2/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// An instance of `ListBatchUpdateData` takes section indexes and item index paths
/// and performs cleanup on init in order to perform a crash-free
/// update via `UICollectionView.performBatchUpdates(_:completion:)`.
public final class ListBatchUpdateData {
    /// Section insert indexes.
    public let insertSections: IndexSet

    /// Section delete indexes.
    public let deleteSections: IndexSet

    /// Section moves.
    public let moveSections: Set<ListMoveIndex>

    /// Item insert index paths.
    public let insertIndexPaths: [IndexPath]

    /// Item delete index paths.
    public let deleteIndexPaths: [IndexPath]

    /// Item moves.
    public let moveIndexPaths: [ListMoveIndexPath]

    /// Creates a new batch update object with section and item operations.
    ///
    /// - Parameters:
    ///   - insertSections: Section indexes to insert.
    ///   - deleteSections: Section indexes to delete.
    ///   - moveSections: Section moves.
    ///   - insertIndexPaths: Item index paths to insert.
    ///   - deleteIndexPaths: Item index paths to delete.
    ///   - moveIndexPaths: Item index paths to move.
    public init(
        insertSections: IndexSet,
        deleteSections: IndexSet,
        moveSections: Set<ListMoveIndex>,
        insertIndexPaths: [IndexPath],
        deleteIndexPaths: [IndexPath],
        moveIndexPaths: [ListMoveIndexPath]) {
        var mMoveSections = moveSections
        var mDeleteSections = deleteSections
        var mInsertSections = insertSections
        var mMoveIndexPaths = moveIndexPaths

        // these collections should NEVER be mutated during cleanup passes,
        // otherwise sections that have multiple item changes
        // (e.g. a moved section that has a delete + reload
        // on different index paths w/in the section) will only
        // convert one of the item changes into a section delete+insert.
        // this will fail hard and be VERY difficult to debug
        var fromDict: [Int: ListMoveIndex] = [:]
        var toDict: [Int: ListMoveIndex] = [:]
        for move in moveSections {
            let from = move.from
            let to = move.to

            // if the move is already deleted or inserted,
            // discard it because count-changing operations must match with data source changes
            if deleteSections.contains(from) || insertSections.contains(to) {
                mMoveSections.remove(move)
            } else {
                fromDict[from] = move
                toDict[to] = move
            }
        }

        var mInsertIndexPaths = insertIndexPaths

        // avoid a flaky UICollectionView bug when deleting from the same index path twice
        // exposes a possible data source inconsistency issue
        var mDeleteIndexPaths = Array(Set(deleteIndexPaths))

        // avoids a bug where a cell is animated twice
        // and one of the snapshot cells is never removed from the hierarchy
        mDeleteIndexPaths.cleanIndexPathsWith(
            dictionary: fromDict,
            moves: &mMoveSections,
            deletes: &mDeleteSections,
            inserts: &mInsertSections
        )

        // prevents a bug where UICollectionView corrupts the heap memory
        // when inserting into a section that is moved
        mInsertIndexPaths.cleanIndexPathsWith(
            dictionary: toDict,
            moves: &mMoveSections,
            deletes: &mDeleteSections,
            inserts: &mInsertSections
        )

        var moveIndexPathsRemoves = Set<ListMoveIndexPath>()
        var moveSectionRemoves = Set<ListMoveIndex>()
        for move in moveIndexPaths {
            // if the section w/ an index path move is deleted, just drop the move
            if deleteSections.contains(move.from.section) {
                moveIndexPathsRemoves.insert(move)
            }

            // if a move is inside a section that is moved,
            // convert the section move to a delete+insert
            if let sectionMove = fromDict[move.from.section] {
                moveIndexPathsRemoves.insert(move)
                moveSectionRemoves.insert(sectionMove)
                mDeleteSections.insert(sectionMove.from)
                mInsertSections.insert(sectionMove.to)
            }
        }

        mMoveIndexPaths = mMoveIndexPaths.filter { !moveIndexPathsRemoves.contains($0) }
        mMoveSections = mMoveSections.filter { !moveSectionRemoves.contains($0) }

        self.deleteSections = mDeleteSections
        self.insertSections = mInsertSections
        self.moveSections = mMoveSections
        self.deleteIndexPaths = mDeleteIndexPaths
        self.insertIndexPaths = mInsertIndexPaths
        self.moveIndexPaths = mMoveIndexPaths
    }
}

extension ListBatchUpdateData: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)); deleteSections: \(deleteSections.count);" +
            " insertSections: \(insertSections.count); moveSections: \(moveSections.count);" +
            " deleteIndexPaths: \(deleteIndexPaths.count);" +
            " insertIndexPaths: \(insertIndexPaths.count);>"
    }
}

fileprivate extension Array where Element == IndexPath {
    mutating func cleanIndexPathsWith(
        dictionary: [Int: ListMoveIndex],
        moves: inout Set<ListMoveIndex>,
        deletes: inout IndexSet, inserts: inout IndexSet) {
        for index in stride(from: self.count - 1, through: 0, by: -1) {
            let indexPath = self[index]
            print(indexPath.section)
            if let move = dictionary[indexPath.section] {
                self.remove(at: index)
                convert(move: move, fromMoves: &moves, toDeletes: &deletes, andInserts: &inserts)
            }
        }
    }

    private func convert(
        move: ListMoveIndex,
        fromMoves moves: inout Set<ListMoveIndex>,
        toDeletes deletes: inout IndexSet,
        andInserts inserts: inout IndexSet) {
        moves.remove(move)

        // add a delete and insert respecting the move's from and to sections
        // delete + insert will result in reloading the entire section
        deletes.insert(move.from)
        inserts.insert(move.to)
    }
}
