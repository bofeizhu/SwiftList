//
//  ListBatchContext.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/17/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Objects conforming to the ListBatchContext protocol provide a way for section controllers
/// to mutate their cells or reload everything within the section.
public protocol ListBatchContext: AnyObject {
    /// Reloads cells in the section controller.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller who's cells need reloading.
    ///   - indexes: The indexes of items that need reloading.
    func sectionController(
        _ sectionController: ListSectionController,
        reloadItemsAt indexes: IndexSet)

    /// Inserts cells in the list.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller who's cells need inserting.
    ///   - indexes: The indexes of items that need inserting.
    func sectionController(
        _ sectionController: ListSectionController,
        insertItemsAt indexes: IndexSet)

    /// Deletes cells in the list.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller who's cells need deleted.
    ///   - indexes: The indexes of items that need deleting.
    func sectionController(
        _ sectionController: ListSectionController,
        deleteItemsAt indexes: IndexSet)

    /// Moves a cell from one index to another within the section controller.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller who's cell needs moved.
    ///   - index: The index the cell is currently in.
    ///   - newIndex: The index the cell should move to.
    func sectionController(
        _ sectionController: ListSectionController,
        moveItemfrom index: Int,
        to newIndex: Int)

    /// Reloads the entire section controller.
    ///
    /// - Parameter sectionController: The section controller who's cells need reloading.
    func reload(_ sectionController: ListSectionController)
}
