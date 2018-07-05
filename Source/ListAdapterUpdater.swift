//
//  ListAdapterUpdater.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 An `ListAdapterUpdater` is a concrete type that conforms to `ListUpdatingDelegate`.
 It is an out-of-box updater for `ListAdapter` objects to use.
 
 - Note: This updater performs re-entrant, coalesced updating for a list. It also uses a least-minimal diff
 for calculating UI updates when `ListAdapter` calls
 `performUpdateWith(collectionView:fromObjects:toObjects:completion:)`.
 */
public final class ListAdapterUpdater {

    /**
     The delegate that receives events with data on the performance of a transition.
     */
    public weak var delegate: ListAdapterUpdaterDelegate?

    /**
     A flag indicating if a move should be treated as a "delete, then insert" operation.
     */
    public var movesAsDeletesInserts: Bool = false

    /**
     A flag indicating whether this updater should skip diffing and simply call
     `reloadData` for updates when the collection view is not in a window. The default value is `true`.

     - Note: This will result in better performance, but will not generate the same delegate
     callbacks. If using a custom layout, it will not receive `prepareForCollectionViewUpdates(_:)`.
     */
    public var allowsBackgroundReloading: Bool = true

    /**
     Time, in seconds, to wait and coalesce batch updates. Default is 0.
     */
    public var coalescanceTime: TimeInterval = 0

    /**
     A bitmask of experiments to conduct on the updater.
     */
    public var experiments: ListExperiment = .listExperimentNone

    //MARK: Private API
    var fromObjects: [AnyListDiffable]?
    var toObjectsClosure: ListToObjectClosure?
    var pendingTransitionToObjects: [AnyListDiffable]?
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
        return hasQueuedReloadData || batchUpdates.hasChanges
        || fromObjects != nil || toObjectsClosure != nil
    }

    init() {
        assert(Thread.isMainThread, "Must be on the main thread")
    }
    
    func performReloadDataWith(collectionViewClosure: ListCollectionViewClosure) {
        assert(Thread.isMainThread, "Must be on the main thread")
        
        var completionClosures = self.completionClosures
        
        cleanStateBeforeUpdates()
        
        func executeCompletionClosures(finished: Bool) {
            for closure in completionClosures {
                closure(finished)
            }
            state = .idle
        }
        
        // bail early if the collection view has been deallocated in the time since the update was queued
        guard let collectionView = collectionViewClosure() else {
            cleanStateAfterUpdates()
            executeCompletionClosures(finished: false)
            return
        }
        
        // item updates must not send mutations to the collection view while we are reloading
        state = .executingBatchUpdateClosure
        
        if let reloadUpdates = reloadUpdates {
            reloadUpdates()
        }
        
        // execute all stored item update closures even if we are just calling reloadData. the actual collection view
        // mutations will be discarded, but clients are encouraged to put their actual /data/ mutations inside the
        // update closure as well, so if we don't execute the closure the changes will never happen
        for itemUpdateClosure in batchUpdates.itemUpdateClosures {
            itemUpdateClosure()
        }
        
        // add any completion blocks from item updates. added after item blocks are executed in order to capture any
        // re-entrant updates
        completionClosures.append(contentsOf: batchUpdates.itemCompletionClosures)
        
        state = .executedBatchUpdateClosure
        cleanStateAfterUpdates()
        
        delegate?.listAdapterUpdater(self, willReloadDataForCollectionView: collectionView)
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        
        delegate?.listAdapterUpdater(self, didReloadDataForCollectionView: collectionView)
        
        executeCompletionClosures(finished: true)
    }
    
//    - (void)performBatchUpdatesWithCollectionViewClosure:(IGListCollectionViewClosure)collectionViewClosure;
//    - (void)cleanStateBeforeUpdates;
    
    
}

private extension ListAdapterUpdater {
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
        
        // removes all completion closures. Done before updates to start collecting completion blocks for coalesced
        // or re-entrant object updates
        completionClosures.removeAll()
    }
    
    func cleanStateAfterUpdates() {
        batchUpdates = ListBatchUpdates()
    }
}
