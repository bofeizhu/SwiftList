//
//  ListDisplayDelegate.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/19/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Implement this protocol to receive display events for a section controller when it is on screen.
public protocol ListDisplayDelegate: AnyObject {
    /// Tells the delegate that the specified section controller is about to be displayed.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter for the section controller.
    ///   - sectionController: The section controller about to be displayed.
    func listAdapter(
        _ listAdapter: ListAdapter,
        willDisplay sectionController: ListSectionController)
    
    /// Tells the delegate that the specified section controller is no longer being displayed.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter for the section controller.
    ///   - sectionController: he section controller that is no longer displayed.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didEndDisplaying sectionController: ListSectionController)
    
    /// Tells the delegate that a cell in the specified list is about to be displayed.
    ///
    /// - Parameters:
    ///   - listAdapter: The list adapter in which the cell will display.
    ///   - sectionController: The section controller that is displaying the cell.
    ///   - cell: The cell about to be displayed.
    ///   - index: The index of the cell in the section.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        willDisplayCell cell: UICollectionViewCell,
        at index: Int)
    
    /// Tells the delegate that a cell in the specified list is no longer being displayed.
    ///
    /// - Parameters:
    ///   - listAdaper: The list adapter in which the cell was displayed.
    ///   - sectionController: The section controller that is no longer displaying the cell.
    ///   - cell: The cell that is no longer displayed.
    ///   - index: The index of the cell in the section.
    func listAdapter(
        _ listAdaper: ListAdapter,
        sectionController: ListSectionController,
        didEndDisplayingCell cell: UICollectionViewCell,
        at index: Int)
}
