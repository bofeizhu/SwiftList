//
//  ListSingleSectionController.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// This section controller is meant to make building simple, single-cell lists easier. By providing
/// the type of cell, a block to configure the cell, and a block to return the size of a cell, you
/// can use an `ListAdapter`-powered list with a simpler architecture.
public final class ListSingleSectionController: ListSectionController {
    /// An optional delegate that handles selection and deselection.
    weak public var selectionDelegate: ListSingleSectionControllerSelectionDelegate?
    
}

/// A delegate that can receive selection events on an `ListSingleSectionController`.
public protocol ListSingleSectionControllerSelectionDelegate: AnyObject {
    /// Tells the delegate that the section controller was selected.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller that was selected.
    ///   - object: The model for the given section.
    func didSelect(_ sectionController: ListSingleSectionController, with object: AnyListDiffable)
    
    /// Tells the delegate that the section controller was deselected.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller that was deselected.
    ///   - object: The model for the given section.
    func didDeselect(_ sectionController: ListSingleSectionController, with object: AnyListDiffable)
}

/// A closure used to configure cells.
///
/// - Parameters:
///   - item: The model with which to configure the cell.
///   - cell: The cell to configure.
public typealias ListSingleSectionCellConfigureClosure =
    (_ item: AnyListDiffable, _ cell: UICollectionViewCell) -> Void

/// A closure that returns the size for the cell given the collection context.
///
/// - Parameters:
///   - item: The model with which to configure the cell.
///   - collectionContext: The collection context for the section.
/// - Returns: The size for the cell.
public typealias ListSingleSectionCellSizeClosure =
    (_ item: AnyListDiffable, _ collectionContext: ListCollectionContext?) -> CGSize



