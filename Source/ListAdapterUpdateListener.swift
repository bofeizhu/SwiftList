//
//  ListAdapterUpdateListener.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/17/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The type of update that was performed by an `ListAdapter`.
///
/// - performUpdates: `ListAdapter.performUpdates(animated:completion:)` was executed.
/// - reloadData: `ListAdapter.reloadData(completion:)` was executed.
/// - itemUpdates: `ListAdapter.performBatchUpdates(_:animated:completion:)` was executed.
public enum ListAdapterUpdateType {
    case performUpdates
    case reloadData
    case itemUpdates
}

/// Conform to this protocol to receive events about `ListAdapter` updates.
public protocol ListAdapterUpdateListener: AnyObject {
    /// Notifies a listener that the listAdapter was updated.
    ///
    /// - Parameters:
    ///   - listAdapter: The `ListAdapter` that updated.
    ///   - update: The type of update executed.
    ///   - animated: A flag indicating if the update was animated. Always `false` for 
    ///         `ListAdapterUpdateType.reloadData`.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didFinishUpdate update: ListAdapterUpdateType,
        animated: Bool)
}
