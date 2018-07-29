//
//  ListAdapterUpdaterDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// A protocol that receives events about `ListAdapterUpdater` operations.
public protocol ListAdapterUpdaterDelegate: AnyObject {
    
    /// Notifies the delegate that the updater will call `performBatchUpdates(_:completion:)`
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - collectView: The collection view that will perform the batch updates.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willPerformBatchUpdatesForCollectionView collectView: UICollectionView)

    /// Notifies the delegate that the updater successfully finished
    /// `performBatchUpdates(_:completion:)`
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - updates: The batch updates that were applied to the collection view.
    ///   - collectionView: The collection view that performed the batch updates.
    /// - Note: This event is called in the completion closure of the batch update.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        didPerformBatchUpdates updates: ListBatchUpdateData,
        forCollectionView collectionView: UICollectionView)

    /// Notifies the delegate that the updater will call `UICollectionView.insertItems(at:)`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - indexPaths: An array of index paths that will be inserted.
    ///   - collectionView: The collection view that will perform the insert.
    /// - Note: This event is only sent when outside of `performBatchUpdates(_:completion:)`.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willInsertItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView)

    /// Notifies the delegate that the updater will call `UICollectionView.deleteItems(at:)`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - indexPaths: An array of index paths that will be deleted.
    ///   - collectionView: The collection view that will perform the delete.
    /// - Note: This event is only sent when outside of `performBatchUpdates(_:completion:)`.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willDeleteItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView)

    /// Notifies the delegate that the updater will call `UICollectionView.moveItem(at:to:)`
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - indexPath: The index path of the item that will be moved.
    ///   - newIndexPath: The index path to move the item to.
    ///   - collectionView: The collection view that will perform the move.
    /// - Note: This event is only sent when outside of `performBatchUpdates(_:completion:)`.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willMoveAt indexPath: IndexPath,
        to newIndexPath: IndexPath,
        forCollectionView collectionView: UICollectionView)

    /// Notifies the delegate that the updater will call `UICollectionView.reloadItems(at:)`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - indexPaths: An array of index paths that will be reloaded.
    ///   - collectionView: The collection view that will perform the reload.
    /// - Note: This event is only sent when outside of `performBatchUpdates(_:completion:)`
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadItemsAt indexPaths: [IndexPath],
        forCollectionView collectionView: UICollectionView)

    /// Notifies the delegate that the updater will call `UICollectionView.reloadSections(_:)`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - sections: he sections that will be reloaded
    ///   - collectionView: he collection view that will perform the reload.
    /// - Note: This event is only sent when outside of `performBatchUpdates(_:completion:)`.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadSections sections: IndexSet,
        forCollectionView collectionView: UICollectionView)
    
    /// Notifies the delegate that the updater will call `UICollectionView.reloadData()`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - collectionView: The collection view that will be reloaded.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        willReloadDataForCollectionView collectionView: UICollectionView)
    
    /// Notifies the delegate that the updater successfully called `UICollectionView.reloadData()`.
    ///
    /// - Parameters:
    ///   - listAdapterUpdater: The adapter updater owning the transition.
    ///   - collectionView: The collection view that reloaded.
    func listAdapterUpdater(
        _ listAdapterUpdater: ListAdapterUpdater,
        didReloadDataForCollectionView collectionView: UICollectionView)
}
