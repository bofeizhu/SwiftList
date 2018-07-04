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
    public var movesAsDeletesInserts: Bool

    /**
     A flag indicating whether this updater should skip diffing and simply call
     `reloadData` for updates when the collection view is not in a window. The default value is `true`.

     - Note: This will result in better performance, but will not generate the same delegate
     callbacks. If using a custom layout, it will not receive `prepareForCollectionViewUpdates(_:)`.
     */
    public var allowsBackgroundReloading: Bool

    /**
     Time, in seconds, to wait and coalesce batch updates. Default is 0.
     */
    public var coalescanceTime: TimeInterval

    /**
     A bitmask of experiments to conduct on the updater.
     */
    public var experiments: ListExperiment

    //MARK: Internal API
    var fromObjects: [AnyListDiffable]?
    

    init() {
        assert(Thread.isMainThread, "Must be on the main thread")
        
    }
}
