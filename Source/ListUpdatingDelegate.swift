//
//  ListUpdatingDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import DifferenceKit

/// Implement this protocol in order to handle both section and row based update events.
/// Implementation should forward or coalesce these events to a backing store or collection.
public protocol ListUpdatingDelegate: AnyObject {
    /// Tells the delegate to perform a section transition from an old array of objects to
    /// a new one.
    ///
    /// - Parameters:
    ///   - collectionViewClosure: A closure returning the collecion view to perform updates on.
    ///   - fromObjects: The previous objects in the collection view.
    ///         Objects must conform to `ListDiffable`.
    ///   - toObjectsClosure: A closure returning the new objects in the collection view.
    ///         Objects must conform to `ListDiffable`.
    ///   - animated: A flag indicating if the transition should be animated.
    ///   - objectTransitionClosure: A closure that must be called when the adapter applies
    ///         changes to the collection view.
    ///   - completion: A completion closure to execute when the update is finished.
    /// - Note: Implementations determine how to transition between objects.
    /// You can perform a diff on the objects, reload each section, or simply call `reloadData()`
    /// on the collection view. In the end, the collection view must be setup with a section
    /// for each object in the `toObjects` array.
    ///
    /// The `objectTransitionClosure` closure should be called prior to making any
    /// `UICollectionView` updates, passing in the `toObjects` that the updater is applying.
    func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        fromObjects: [AnyDifferentiable]?,
        toObjectsClosure: ListToObjectsClosure?,
        animated: Bool,
        objectTransitionClosure: @escaping ListObjectTransitionClosure,
        completion: ListUpdatingCompletion?)

    /// Perform an item update closure in the collection view.
    ///
    /// - Parameters:
    ///   - collectionViewClosure: A closure returning the collecion view to perform updates on.
    ///   - animated: A flag indicating if the transition should be animated.
    ///   - itemUpdates: A closure containing all of the updates.
    ///   - completion: A completion closure to execute when the update is finished.
    func performUpdateWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        animated: Bool,
        itemUpdates: @escaping ListItemUpdateClosure,
        completion: ListUpdatingCompletion?)

    /// Tells the delegate to perform item inserts at the given index paths.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view on which to perform the transition.
    ///   - indexPaths: The index paths to insert items into.
    func collectionView(_ collectionView: UICollectionView, insertItemsAt indexPaths: [IndexPath])

    /// Tells the delegate to perform item deletes at the given index paths.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view on which to perform the transition.
    ///   - indexPaths: The index paths to delete items from.
    func collectionView(_ collectionView: UICollectionView, deleteItemsAt indexPaths: [IndexPath])

    /// Tells the delegate to move an item from and to given index paths.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view on which to perform the transition.
    ///   - indexPath: The source index path of the item to move.
    ///   - newIndexPath: The destination index path of the item to move.
    func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath)

    /// Tells the delegate to reload an item from and to given index paths.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view on which to perform the transition.
    ///   - indexPath: The source index path of the item to reload.
    ///   - newIndexPath: The destination index path of the item to reload.
    /// - Note: Since `UICollectionView` is unable to handle calling
    ///     `UICollectionView.reloadItems(at:)` safely while also executing insert and delete
    ///     operations in the same batch updates, the updater must know about the origin and
    ///     destination of the reload to perform a safe transition.
    func collectionView(
        _ collectionView: UICollectionView,
        reloadItemAt indexPath: IndexPath,
        to newIndexPath: IndexPath)

    /// Tells the delegate to move a section from and to given indexes.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view on which to perform the transition.
    ///   - section: The source index of the section to move.
    ///   - newSection: The destination index of the section to move.
    func collectionView(
        _ collectionView: UICollectionView,
        moveSection section: Int,
        toSection newSection: Int)

    /// Completely reload each section in the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to reload.
    ///   - sections: The sections to reload.
    func collectionView(_ collectionView: UICollectionView, reloadSections sections: IndexSet)

    /// Completely reload data in the collection.
    ///
    /// - Parameters:
    ///   - collectionViewClosure: A closure returning the collecion view to reload.
    ///   - reloadUpdateClosure: A closure that must be called when the adapter reloads
    ///         the collection view.
    ///   - completion: A completion closure to execute when the reload is finished.
    func reloadDataWith(
        collectionViewClosure: @escaping ListCollectionViewClosure,
        reloadUpdateClosure: @escaping ListReloadUpdateClosure,
        completion: ListUpdatingCompletion?)
}

/// A completion closure to execute when updates are finished.
///
/// - Parameter finished: Specifies whether or not the update finished.
public typealias ListUpdatingCompletion = (_ finished: Bool) -> Void

///  A closure to be called when the adapter applies changes to the collection view.
///
/// - Parameter toObjects: The new objects in the collection.
public typealias ListObjectTransitionClosure = (_ toObjects: [AnyDifferentiable]) -> Void

/// A closure that contains all of the updates.
public typealias ListItemUpdateClosure = () -> Void

/// A closure to be called when an adapter reloads the collection view.
public typealias ListReloadUpdateClosure = () -> Void

/// A closure that returns an array of objects to transition to.
public typealias ListToObjectsClosure = () -> [AnyDifferentiable]?

/// A closure that returns a collection view to perform updates on.
public typealias ListCollectionViewClosure = () -> UICollectionView?
