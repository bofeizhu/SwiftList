//
//  ListWorkingRangeDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/19/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Implement this protocol to receive working range events for a list.
///
/// The working range is a range *near* the viewport in which you can begin preparing content for
/// display. For example, you could begin decoding images, or warming text caches.
public protocol ListWorkingRangeDelegate: AnyObject {
    
    /// Notifies the delegate that an section controller will enter the working range.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter controlling the list.
    ///   - sectionController: The section controller entering the range.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerWillEnterWorkingRange sectionController: ListSectionController)
    
    /// Notifies the delegate that an section controller exited the working range.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter controlling the list.
    ///   - sectionController: The section controller that exited the range.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerDidExitWorkingRange sectionController: ListSectionController)
}
