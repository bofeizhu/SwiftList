//
//  ListTransitionDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/19/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Conform to `ListTransitionDelegate` to provide customized layout information for a collection
/// view.
public protocol ListTransitionDelegate: AnyObject {
    
    /// Asks the delegate to customize and return the starting layout information for an item being
    /// inserted into the collection view.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter controlling the list.
    ///   - sectionController: The section controller to perform the transition on.
    ///   - layoutAttributes: The starting layout information for an item being inserted into the
    ///       collection view.
    ///   - index: The index of the item being inserted.
    /// - Returns: The layout information for an item being inserted into the collection view.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        customizedInitialLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes,
        at index: Int
    ) -> UICollectionViewLayoutAttributes
    
    /// Asks the delegate to customize and return the final layout information for an item that is
    /// about to be removed from the collection view.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter controlling the list.
    ///   - sectionController: The section controller to perform the transition on.
    ///   - layoutAttributes: The final layout information for an item that is about to be removed
    ///       from the collection view.
    ///   - index: The index of the item being deleted.
    /// - Returns: The final layout information for an item that is about to be removed from the
    ///     collection view.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        customizedFinalLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes,
        at index: Int
    ) -> UICollectionViewLayoutAttributes
}
