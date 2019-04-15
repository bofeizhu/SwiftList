//
//  ListAdapterMoveDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import DifferenceKit

/// Conform to `ListAdapterMoveDelegate` to receive interactive reordering requests.
public protocol ListAdapterMoveDelegate: AnyObject {
    /// Asks the delegate to move a section object as the result of interactive reordering.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter sending this information.
    ///   - object: The object that was moved
    ///   - objects: The array of objects prior to the move.
    ///   - newObjects: The array of objects after the move.
    func listAdapter(
        _ listAdapter: ListAdapter,
        move object: AnyDifferentiable,
        from objects: [AnyDifferentiable],
        to newObjects: [AnyDifferentiable])
}
