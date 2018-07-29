//
//  ListAdapterDataSource.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Implement this protocol to provide data to an `ListAdapter`.
public protocol ListAdapterDataSource: AnyObject {
    
    /// Asks the data source for the objects to display in the list.
    ///
    /// - Parameter listAdapter: The list adapter requesting this information.
    /// - Returns: An array of objects for the list.
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable]
    
    /// Asks the data source for a section controller for the specified object in the list.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter requesting this information.
    ///   - object: An object in the list.
    /// - Returns: A new section controller instance that can be displayed in the list.
    /// - Note: New section controllers should be initialized here for objects when asked. You may
    /// pass any other data to the section controller at this time.
    ///
    /// Section controllers are initialized for all objects whenever the `ListAdapter` is created,
    /// updated, or reloaded. Section controllers are reused when objects are moved or updated.
    /// Maintaining the `diffIdentifier` guarantees this.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable
    ) -> ListSectionController
    
    /// Asks the data source for a view to use as the collection view background when the list is
    /// empty.
    ///
    /// - Parameter listAdapter: The list adapter requesting this information.
    /// - Returns: A view to use as the collection view background, or `nil` if you don't want a
    ///     background view.
    /// - Note: This method is called every time the list adapter is updated. You are free to return
    ///     new views every time, but for performance reasons you may want to retain the view and
    ///     return it here. The infra is only responsible for adding the background view and
    ///     maintaining its visibility.
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView?
}
