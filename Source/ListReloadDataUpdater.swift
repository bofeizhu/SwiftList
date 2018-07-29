//
//  ListReloadDataUpdater.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// An `ListReloadDataUpdater` is a concrete type that conforms to `ListUpdatingDelegate`.
/// It is an out-of-box updater for `IGListAdapter` objects to use.
/// - Note: This updater performs simple, synchronous updates using `UICollectionView.reloadData()`.
public final class ListReloadDataUpdater: ListUpdatingDelegate {
    // MARK: - ListUpdatingDelegate
    public func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        fromObjects: [AnyListDiffable]?,
        toObjectsClosure: ListToObjectsClosure?,
        animated: Bool,
        objectTransitionClosure: @escaping ListObjectTransitionClosure,
        completion: ListUpdatingCompletion?) {
        if let toObjectsClosure = toObjectsClosure {
            let toObjects = toObjectsClosure() ?? []
            objectTransitionClosure(toObjects)
        }
        synchronousReloadData(with: collectionViewClosure())
        guard let completion = completion else { return }
        completion(true)
    }
    
    public func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        animated: Bool,
        itemUpdates: @escaping ListItemUpdateClosure,
        completion: ListUpdatingCompletion?) {
        itemUpdates()
        synchronousReloadData(with: collectionViewClosure())
        guard let completion = completion else { return }
        completion(true)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        insertItemsAt indexPaths: [IndexPath]) {
        synchronousReloadData(with: collectionView)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        deleteItemsAt indexPaths: [IndexPath]) {
        synchronousReloadData(with: collectionView)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath) {
        synchronousReloadData(with: collectionView)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        reloadItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath) {
        synchronousReloadData(with: collectionView)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        moveSection section: Int,
        toSection newSection: Int) {
        synchronousReloadData(with: collectionView)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        reloadSections sections: IndexSet) {
        synchronousReloadData(with: collectionView)
    }
    
    public func reloadDataWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        reloadUpdateClosure: @escaping ListReloadUpdateClosure,
        completion: ListUpdatingCompletion?) {
        reloadUpdateClosure()
        synchronousReloadData(with: collectionViewClosure())
        guard let completion = completion else { return }
        completion(true)
    }
}

// MARK: - Private Helpers
private extension ListReloadDataUpdater {
    func synchronousReloadData(with collectionView: UICollectionView?) {
        guard let collectionView = collectionView else {
            return
        }
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}
