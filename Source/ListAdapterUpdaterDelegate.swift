//
//  ListAdapterUpdaterDelegate.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 A protocol that receives events about `ListAdapterUpdater` operations.
 */

public protocol ListAdapterUpdaterDelegate: AnyObject {
    /**
     Notifies the delegate that the updater will call `UICollectionView.performBatchUpdates(_:completion:)`.
     
     - Parameters:
        - listAdapterUpdater: The adapter updater owning the transition.
        - collectionView: The collection view that will perform the batch updates.
     */
    func listAdapterUpdater(_ listAdapterUpdater: ListAdapterUpdater,
                            willPerformBatchUpdatesWithCollectionView collectView: UICollectionView)
    
    /**
     Notifies the delegate that the updater successfully finished `UICollectionView.performBatchUpdates(_:completion:)`.
     
     - Parameters:
        - listAdapterUpdater: The adapter updater owning the transition.
        - updates: The batch updates that were applied to the collection view.
        - collectionView: The collection view that performed the batch updates.
     
     Note: This event is called in the completion block of the batch update.
     */
    func listAdapterUpdater(_ listAdapterUpdater: ListAdapterUpdater,
                            didPerformBatchUpdates updates: ListBatchUpdateData,
                            collectionView: UICollectionView)
}
