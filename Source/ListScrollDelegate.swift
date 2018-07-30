//
//  ListScrollDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/19/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Implement this protocol to receive display events for a section controller when it is on screen.
public protocol ListScrollDelegate: AnyObject {
    /// Tells the delegate that the section controller was scrolled on screen.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter whose collection view was scrolled.
    ///   - sectionController: The visible section controller that was scrolled.
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController)

    /// Tells the delegate that the section controller will be dragged on screen.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter whose collection view will drag.
    ///   - sectionController: The visible section controller that will drag.
    func listAdapter(
        _ listAdapter: ListAdapter,
        willBeginDragging sectionController: ListSectionController)

    /// Tells the delegate that the section controller did end dragging on screen.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter whose collection view ended dragging.
    ///   - sectionController: The visible section controller that ended dragging.
    ///   - decelerate: `true` if section controller will decelerate, `false` otherwise.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didEndDragging sectionController: ListSectionController,
        willDecelerate decelerate: Bool)

    /// Tells the delegate that the section controller did end decelerating on screen.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter whose collection view ended decelerating.
    ///   - sectionController: The visible section controller that ended decelerating.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didEndDecelerating sectionController: ListSectionController)
}
