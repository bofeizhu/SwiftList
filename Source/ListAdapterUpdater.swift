//
//  ListAdapterUpdater.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import DifferenceKit

/// An `ListAdapterUpdater` is a concrete type that conforms to `ListUpdatingDelegate`.
/// It is an out-of-box updater for `ListAdapter` objects to use.
///  - Note: This updater performs re-entrant, coalesced updating for a list.
///     It also uses a least-minimal diff for calculating UI updates when `ListAdapter` calls
///     `performUpdateWith(collectionView:fromObjects:toObjects:completion:)`.
public final class ListAdapterUpdater {
    /// The delegate that receives events with data on the performance of a transition.
    public weak var delegate: ListAdapterUpdaterDelegate?

    /// A flag indicating if a move should be treated as a "delete, then insert" operation.
    public var movesAsDeletesInserts: Bool = false

    /// A flag indicating whether this updater should skip diffing and simply call `reloadData`
    /// for updates when the collection view is not in a window. The default value is `true`.
    /// - Note: This will result in better performance, but will not generate the same delegate
    ///     callbacks. If using a custom layout, it will not receive
    ///     `prepareForCollectionViewUpdates(_:)`.
    public var allowsBackgroundReloading: Bool = true

    /// Time, in seconds, to wait and coalesce batch updates. Default is 0.
    public var coalescanceTime: Int = 0

    /// A bitmask of experiments to conduct on the updater.
    public var experiments: ListExperiment = .none

    // MARK: Private API
    var fromObjects: [AnyDifferentiable]?
    var toObjectsClosure: ListToObjectsClosure?
    var pendingTransitionToObjects: [AnyDifferentiable]?
    var completionClosures: [ListUpdatingCompletion] = []

    // the default is to use animations unless NO is passed
    var queuedUpdateIsAnimated: Bool = true

    var batchUpdates: ListBatchUpdates = ListBatchUpdates()
    var objectTransitionClosure: ListObjectTransitionClosure?
    var reloadUpdates: ListReloadUpdateClosure?
    private(set) var hasQueuedReloadData: Bool = false
    var state: ListBatchUpdateState = .idle
    var applyingUpdateData: ListBatchUpdateData?

    var hasChanges: Bool {
        return hasQueuedReloadData || batchUpdates.hasChanges ||
            fromObjects != nil || toObjectsClosure != nil
    }

    public init() {
        dispatchPrecondition(condition: .onQueue(.main))
    }

    func performReloadDataWith(collectionViewClosure: ListCollectionViewClosure) {
        dispatchPrecondition(condition: .onQueue(.main))

        var completionClosures = self.completionClosures
        cleanStateBeforeUpdates()

        let executeCompletionClosures = {[unowned self] (finished: Bool) in
            for closure in completionClosures {
                closure(finished)
            }
            self.state = .idle
        }

        // bail early if the collection view has been deallocated in the time
        // since the update was queued
        guard let collectionView = collectionViewClosure() else {
            cleanStateAfterUpdates()
            executeCompletionClosures(false)
            return
        }

        // item updates must not send mutations to the collection view while we are reloading
        state = .executingBatchUpdateClosure

        if let reloadUpdates = reloadUpdates {
            reloadUpdates()
        }

        // execute all stored item update closures even if we are just calling reloadData.
        // the actual collection view mutations will be discarded,
        // but clients are encouraged to put their actual /data/ mutations inside the
        // update closure as well, so if we don't execute the closure the changes will never happen
        for itemUpdateClosure in batchUpdates.itemUpdateClosures {
            itemUpdateClosure()
        }

        // add any completion blocks from item updates. added after item blocks are executed
        // in order to capture any re-entrant updates
        completionClosures.append(contentsOf: batchUpdates.itemCompletionClosures)

        state = .executedBatchUpdateClosure
        cleanStateAfterUpdates()

        delegate?.listAdapterUpdater(self, willReloadDataForCollectionView: collectionView)

        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()

        delegate?.listAdapterUpdater(self, didReloadDataForCollectionView: collectionView)

        executeCompletionClosures(true)
    }

    // TODO: Add Helpers to reduce complexity
    // swiftlint:disable:next cyclomatic_complexity
    func performBatchUpdatesWith(collectionViewClosure: @escaping ListCollectionViewClosure) {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(state == .idle, "Should not call batch updates when state isn't idle")

        // create local variables so we can immediately clean our state
        // but pass these items into the batch update block
        let delegate = self.delegate
        let fromObjects = self.fromObjects
        let toObjectsClosure = self.toObjectsClosure
        var completionClosures = self.completionClosures
        let objectTransitionClosure = self.objectTransitionClosure
        let animated = queuedUpdateIsAnimated
        let batchUpdates = self.batchUpdates

        // clean up all state so that new updates can be coalesced
        // while the current update is in flight
        cleanStateBeforeUpdates()

        let executeCompletionClosures = { [weak self] (finished: Bool) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.applyingUpdateData = nil
            strongSelf.state = .idle

            for closure in completionClosures {
                closure(finished)
            }
        }

        // bail early if the collection view has been deallocated in the time
        // since the update was queued
        guard let collectionView = collectionViewClosure() else {
            cleanStateAfterUpdates()
            executeCompletionClosures(false)
            return
        }

        let toObjects = toObjectsClosure?()

        #if DEBUG
        toObjects?.checkDuplicateDiffIdentifier()
        #endif

        let executeUpdateClosures = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.state = .executingBatchUpdateClosure

            // run the update block so that the adapter can set its items.
            // this makes sure that just before the update is committed
            // that the data source is updated to the /latest/ "toObjects".
            // this makes the data source in sync
            // with the items that the updater is transitioning to
            if let toObjects = toObjects {
                objectTransitionClosure?(toObjects)
            }

            // execute each item update block which should make calls like insert, delete,
            // and reload for index paths
            // we collect all mutations in corresponding sets on self,
            // then filter based on UICollectionView shortcomings
            // call after the objectTransitionBlock
            // so section level mutations happen before any items
            for itemUpdateClosure in batchUpdates.itemUpdateClosures {
                itemUpdateClosure()
            }

            // add any completion blocks from item updates.
            // added after item blocks are executed in order to capture any
            // re-entrant updates
            completionClosures.append(contentsOf: batchUpdates.itemCompletionClosures)

            strongSelf.state = .executedBatchUpdateClosure
        }

        let reloadDataFallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            executeUpdateClosures()
            strongSelf.cleanStateAfterUpdates()
            strongSelf.performBatchUpdatesItemClosureApplied()
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            executeCompletionClosures(true)
        }

        // if the collection view isn't in a visible window, skip diffing and batch updating.
        // execute all transition blocks,
        // reload data, execute completion blocks, and get outta here
        if allowsBackgroundReloading,
            collectionView.window == nil {
            beginPerformBatchUpdatesTo(objects: toObjects)
            reloadDataFallback()
            return
        }

        // disables multiple `performBatchUpdates(_ :)` from happening at the same time
        beginPerformBatchUpdatesTo(objects: toObjects)

        let experiments = self.experiments

        let performDiff = {
            return listDiff(oldArray: fromObjects, newArray: toObjects, option: .equality)
        }

        // closure executed in the first param closure of
        // `UICollectionView.performBatchUpdates(_:completion:)`
        let batchUpdatesClosure = {[weak self] (result: ListIndexSetResult) in
            guard let strongSelf = self else {
                return
            }
            executeUpdateClosures()
            strongSelf.applyingUpdateData = strongSelf.flush(
                collectionView: collectionView,
                withDiffResult: result,
                batchUpdates: strongSelf.batchUpdates,
                fromObjects: fromObjects)
            strongSelf.cleanStateAfterUpdates()
            strongSelf.performBatchUpdatesItemClosureApplied()
        }

        // closure used as the second param of `UICollectionView.performBatchUpdates(_:completion:)`
        let batchUpdatesCompletionBlock = { [weak self] (finished: Bool) in
            guard let strongSelf = self else {
                return
            }
            let oldApplyingUpdateData = strongSelf.applyingUpdateData

            executeCompletionClosures(finished)

            if let oldApplyingUpdateData = oldApplyingUpdateData {
                delegate?.listAdapterUpdater(
                    strongSelf,
                    didPerformBatchUpdates: oldApplyingUpdateData,
                    forCollectionView: collectionView)
            }
            // queue another update in case something changed during batch updates.
            // this method will bail next runloop if there are no changes
            strongSelf.performBatchUpdatesWith(collectionViewClosure: collectionViewClosure)
        }

        // closure that executes the batch update
        let performUpdate = { [weak self] (result: ListIndexSetResult) in
            guard let strongSelf = self else {
                return
            }
            collectionView.layoutIfNeeded()
            delegate?.listAdapterUpdater(
                strongSelf,
                willPerformBatchUpdatesForCollectionView: collectionView)

            if result.changeCount > 100,
                experiments.contains(.reloadDataFallback) {
                reloadDataFallback()
            } else if animated {
                collectionView.performBatchUpdates({
                    batchUpdatesClosure(result)
                }, completion: batchUpdatesCompletionBlock)
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                collectionView.performBatchUpdates({
                    batchUpdatesClosure(result)
                }, completion: { (finished) in
                    CATransaction.commit()
                    batchUpdatesCompletionBlock(finished)
                })
            }
        }

        // temporary test to try out background diffing
        if experiments.contains(.backgroundDiffing) {
            //TODO: experiments
        } else {
            let result = performDiff()
            performUpdate(result)
        }
    }

    func cleanStateBeforeUpdates() {
        queuedUpdateIsAnimated = true

        // destroy to/from transition items
        fromObjects = nil
        toObjectsClosure = nil

        // destroy reloadData state
        reloadUpdates = nil
        hasQueuedReloadData = false

        // remove indexpath/item changes
        objectTransitionClosure = nil

        // removes all completion closures.
        // done before updates to start collecting completion blocks for coalesced
        // or re-entrant object updates
        completionClosures.removeAll()
    }
}

private extension ListAdapterUpdater {
    func cleanStateAfterUpdates() {
        batchUpdates = ListBatchUpdates()
    }

    func performBatchUpdatesItemClosureApplied() {
        pendingTransitionToObjects = nil
    }

    func flush(
        collectionView: UICollectionView,
        withDiffResult diffResult: ListIndexSetResult,
        batchUpdates: ListBatchUpdates,
        fromObjects: [AnyDifferentiable]?
    ) -> ListBatchUpdateData {
        var moves = Set(diffResult.moves)

        // combine section reloads from the diff and manual reloads via `reloadItems(_ :)`
        var reloads = diffResult.updates
        reloads.formUnion(batchUpdates.sectionReloads)

        var inserts = diffResult.inserts
        var deletes = diffResult.deletes

        if movesAsDeletesInserts {
            for move in moves {
                deletes.insert(move.from)
                inserts.insert(move.to)
            }
            // clear out all moves
            moves = []
        }

        // `reloadSections()` is unsafe to use within `performBatchUpdates()`,
        // so instead convert all reloads into deletes+inserts
        convert(
            reloads: &reloads,
            toDeletes: &deletes,
            andInserts: &inserts,
            withResult: diffResult,
            fromObjects: fromObjects)

        let uniqueDeletes = Set(batchUpdates.itemDeletes)
        var reloadDeletePaths: Set<IndexPath> = []
        var reloadInsertPaths: Set<IndexPath> = []
        for reload in batchUpdates.itemReloads {
            if !uniqueDeletes.contains(reload.from) {
                reloadDeletePaths.insert(reload.from)
                reloadInsertPaths.insert(reload.to)
            }
        }

        batchUpdates.delete(items: Array(reloadDeletePaths))
        batchUpdates.insert(items: Array(reloadInsertPaths))

        //TODO: Add experiment

        let data = ListBatchUpdateData(
            insertSections: inserts,
            deleteSections: deletes,
            moveSections: moves,
            insertIndexPaths: batchUpdates.itemInserts,
            deleteIndexPaths: batchUpdates.itemDeletes,
            moveIndexPaths: batchUpdates.itemMoves)

        collectionView.apply(batchUpdateData: data)
        return data
    }

    func beginPerformBatchUpdatesTo(objects: [AnyDifferentiable]?) {
        pendingTransitionToObjects = objects
        state = .queuedBatchUpdate
    }

    func queueUpdateWith(collectionViewClosure: @escaping ListCollectionViewClosure) {
        dispatchPrecondition(condition: .onQueue(.main))
        // dispatch after a given amount of time to coalesce other updates and execute as one
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(coalescanceTime)) { [weak self] in
            guard let strongSelf = self,
                strongSelf.state == .idle,
                strongSelf.hasChanges else {
                return
            }

            if strongSelf.hasQueuedReloadData {
                strongSelf.performReloadDataWith(collectionViewClosure: collectionViewClosure)
            } else {
                strongSelf.performBatchUpdatesWith(collectionViewClosure: collectionViewClosure)
            }
        }
    }
}

extension ListAdapterUpdater: ListUpdatingDelegate {
    public func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        fromObjects: [AnyDifferentiable]?,
        toObjectsClosure: ListToObjectsClosure?,
        animated: Bool,
        objectTransitionClosure: @escaping ListObjectTransitionClosure,
        completion: ListUpdatingCompletion?) {
        dispatchPrecondition(condition: .onQueue(.main))

        // only update the items that we are coming from if it has not been set
        // this allows multiple updates to be called while an update is already in progress,
        // and the transition from -> to will be done on the first `fromObjects` received
        // and the last `toObjects`
        // if `performBatchUpdates()` hasn't applied the update block,
        // then data source hasn't transitioned its state. if an
        // update is queued in between then we must use the pending `toObjects`
        self.fromObjects = self.fromObjects ?? self.pendingTransitionToObjects ?? fromObjects
        self.toObjectsClosure = toObjectsClosure

        // disabled animations will always take priority
        // reset to true in clean state
        queuedUpdateIsAnimated = queuedUpdateIsAnimated && animated

        // always use the last update closure,
        // even though this should always do the exact same thing
        self.objectTransitionClosure = objectTransitionClosure

        if let completion = completion {
            completionClosures.append(completion)
        }

        queueUpdateWith(collectionViewClosure: collectionViewClosure)
    }

    public func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        animated: Bool,
        itemUpdates: @escaping ListItemUpdateClosure,
        completion: ListUpdatingCompletion?) {
        dispatchPrecondition(condition: .onQueue(.main))

        if let completion = completion {
            batchUpdates.append(completionClosure: completion)
        }

        // if already inside the execution of the update closure,
        // immediately unload the itemUpdates closure.
        // the completion closures are executed later in the lifecycle,
        // so that still needs to be added to the batch
        if state == .executingBatchUpdateClosure {
            itemUpdates()
        } else {
            batchUpdates.append(updateClosure: itemUpdates)

            // disabled animations will always take priority
            // reset to true in clean state
            queuedUpdateIsAnimated = queuedUpdateIsAnimated && animated
            queueUpdateWith(collectionViewClosure: collectionViewClosure)
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        insertItemsAt indexPaths: [IndexPath]) {
        dispatchPrecondition(condition: .onQueue(.main))

        if state == .executingBatchUpdateClosure {
            batchUpdates.insert(items: indexPaths)
        } else {
            delegate?.listAdapterUpdater(
                self,
                willInsertItemsAt: indexPaths,
                forCollectionView: collectionView)
            collectionView.insertItems(at: indexPaths)
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        deleteItemsAt indexPaths: [IndexPath]) {
        dispatchPrecondition(condition: .onQueue(.main))

        if state == .executingBatchUpdateClosure {
            batchUpdates.delete(items: indexPaths)
        } else {
            delegate?.listAdapterUpdater(
                self,
                willDeleteItemsAt: indexPaths,
                forCollectionView: collectionView)
            collectionView.deleteItems(at: indexPaths)
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath) {
        if state == .executingBatchUpdateClosure {
            let move = ListMoveIndexPath(from: indexPath, to: newIndexPath)
            batchUpdates.append(move: move)
        } else {
            delegate?.listAdapterUpdater(
                self,
                willMoveAt: indexPath,
                to: newIndexPath,
                forCollectionView: collectionView)
            collectionView.moveItem(at: indexPath, to: newIndexPath)
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        reloadItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath) {
        if state == .executingBatchUpdateClosure {
            let reload = ListReloadIndexPath(from: indexPath, to: newIndexPath)
            batchUpdates.append(reload: reload)
        } else {
            delegate?.listAdapterUpdater(
                self,
                willReloadItemsAt: [indexPath],
                forCollectionView: collectionView)
            collectionView.reloadItems(at: [indexPath])
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        moveSection section: Int,
        toSection newSection: Int) {
        dispatchPrecondition(condition: .onQueue(.main))

        // iOS expects interactive reordering to be movement of items not sections
        // after moving a single-item section controller,
        // you end up with two items in the section for the drop location,
        // and zero items in the section originating at the drag location
        // so, we have to reload data rather than doing a section move

        collectionView.reloadData()

        // It seems that reloadData called during UICollectionView's moveItemAtIndexPath
        // delegate call does not reload all cells as intended
        // So, we further reload all visible sections to make sure none of our cells
        // are left with data that's out of sync with our dataSource
        var visibleSections = IndexSet()
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            visibleSections.insert(indexPath.section)
        }

        delegate?.listAdapterUpdater(
            self,
            willReloadSections: visibleSections,
            forCollectionView: collectionView)

        // prevent double-animation from reloadData + reloadSections
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView.performBatchUpdates({
            collectionView.reloadSections(visibleSections)
        }, completion: { (_) in
            CATransaction.commit()
        })
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        reloadSections sections: IndexSet) {
        dispatchPrecondition(condition: .onQueue(.main))
        if state == .executingBatchUpdateClosure {
            batchUpdates.reload(sections: sections)
        } else {
            delegate?.listAdapterUpdater(
                self,
                willReloadSections: sections,
                forCollectionView: collectionView)
            collectionView.reloadSections(sections)
        }
    }

    public func reloadDataWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        reloadUpdateClosure: @escaping ListReloadUpdateClosure,
        completion: ListUpdatingCompletion?) {
        dispatchPrecondition(condition: .onQueue(.main))

        if let completion = completion {
            completionClosures.append(completion)
        }

        reloadUpdates = reloadUpdateClosure
        hasQueuedReloadData = true
        queueUpdateWith(collectionViewClosure: collectionViewClosure)
    }
}

func convert(
    reloads: inout IndexSet,
    toDeletes deletes: inout IndexSet,
    andInserts inserts: inout IndexSet,
    withResult result: ListIndexSetResult,
    fromObjects: [AnyDifferentiable]?) {
    for index in reloads {
        // if a diff was not performed, there are no changes.
        // instead use the same index that was originally queued
        var diffIdentifier: AnyHashable? = nil
        var from: Int? = index
        var to: Int? = index

        if let fromObjects = fromObjects,
            !fromObjects.isEmpty {
            diffIdentifier = fromObjects[index].differenceIdentifier
            from = result.oldIndexFor(diffIdentifier: diffIdentifier)
            to = result.newIndexFor(diffIdentifier: diffIdentifier)
        }

        // if a reload is queued outside the diff and the object was inserted
        // or deleted it cannot be
        if let from = from {
            reloads.remove(from)
            if let to = to {
                deletes.insert(from)
                inserts.insert(to)
            } else {
                assert(
                    result.deletes.contains(index),
                    "Reloaded section \(index) was not found in deletes with" +
                        " from: \(String(describing: from))," +
                        " to: \(String(describing: to)), deletes: \(deletes)")
            }
        }
    }
}
