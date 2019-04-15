//
//  ListAdapterDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import DifferenceKit

/// Conform to `ListAdapterDelegate` to receive display events for objects in a list.
public protocol ListAdapterDelegate: AnyObject {
    /// Notifies the delegate that a list object is about to be displayed.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter sending this information.
    ///   - object: The object that will display.
    ///   - index: The index of the object in the list.
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: AnyDifferentiable, at index: Int)

    /// Notifies the delegate that a list object is no longer being displayed.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter sending this information.
    ///   - object: The object that ended display.
    ///   - index: The index of the object in the list.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didEndDisplaying object: AnyDifferentiable,
        at index: Int)
}
