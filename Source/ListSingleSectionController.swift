//
//  ListSingleSectionController.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// This section controller is meant to make building simple, single-cell lists easier. By providing
/// the type of cell, a closure to configure the cell, and a closure to return the size of a cell,
/// you can use an `ListAdapter`-powered list with a simpler architecture.
public final class ListSingleSectionController: ListSectionController {
    /// An optional delegate that handles selection and deselection.
    weak public var selectionDelegate: ListSingleSectionControllerSelectionDelegate?
    
    /// Creates a new section controller for a given cell type that will always have only one cell
    /// when present in a list.
    ///
    /// - Parameters:
    ///   - cellClass: The `UICollectionViewCell` subclass for the single cell.
    ///   - configureClosure: A closure that configures the cell with the item given to the section
    ///         controller.
    ///   - sizeClosure: A closure that returns the size for the cell given the collection context.
    /// - Warning: Be VERY CAREFUL not to create retain cycles by holding strong references to: the
    ///     object that owns the adapter (usually `self`) or the `ListAdapter`. Pass in locally
    ///     scoped objects or use `weak` references!
    public init(
        cellClass: AnyClass,
        configureClosure: @escaping ListSingleSectionCellConfigureClosure,
        sizeClosure: @escaping ListSingleSectionCellSizeClosure) {
        self.cellClass = cellClass
        self.configureClosure = configureClosure
        self.sizeClosure = sizeClosure
    }
    
    /// Creates a new section controller for a given nib name and bundle that will always have only
    /// one cell when present in a list.
    ///
    /// - Parameters:
    ///   - nibName: The name of the nib file for the single cell.
    ///   - bundle: The bundle in which to search for the nib file. If `nil`, this method looks for
    ///         the file in the main bundle.
    ///   - configureClosure: A closure that configures the cell with the item given to the section
    ///         controller.
    ///   - sizeClosure: A closure that returns the size for the cell given the collection context.
    /// - Warning: Be VERY CAREFUL not to create retain cycles by holding strong references to: the
    ///     object that owns the adapter (usually `self`) or the `ListAdapter`. Pass in locally
    ///     scoped objects or use `weak` references!
    public init(
        nibName: String,
        bundle: Bundle?,
        configureClosure: @escaping ListSingleSectionCellConfigureClosure,
        sizeClosure: @escaping ListSingleSectionCellSizeClosure) {
        assert(!nibName.isEmpty, "Nib name is empty")
        self.nibName = nibName
        self.bundle = bundle
        self.configureClosure = configureClosure
        self.sizeClosure = sizeClosure
    }
    
    /// Creates a new section controller for a given storyboard cell identifier that will always
    /// have only one cell when present in a list.
    ///
    /// - Parameters:
    ///   - storyboardCellIdentifier: The identifier of the cell prototype in storyboard.
    ///   - configureClosure: A closure that configures the cell with the item given to the section
    ///         controller.
    ///   - sizeClosure: A closure that returns the size for the cell given the collection context.
    /// - Warning: Be VERY CAREFUL not to create retain cycles by holding strong references to: the
    ///     object that owns the adapter (usually `self`) or the `ListAdapter`. Pass in locally
    ///     scoped objects or use `weak` references!
    public init(
        storyboardCellIdentifier: String,
        configureClosure: @escaping ListSingleSectionCellConfigureClosure,
        sizeClosure: @escaping ListSingleSectionCellSizeClosure) {
        assert(!storyboardCellIdentifier.isEmpty, "Storyboard identifier is empty")
        self.identifier = storyboardCellIdentifier
        self.configureClosure = configureClosure
        self.sizeClosure = sizeClosure
    }
    
    // MARK: - ListSectionController Overrides
    public override var numberOfItems: Int {
        return 1
    }
    
    public override func sizeForItem(at index: Int) -> CGSize? {
        guard let item = item,
              let collectionContext = collectionContext else { return nil }
        return sizeClosure(item, collectionContext)
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell? {
        assert(index == 0, "Only one cell is allowed for single section controllers")
        guard let collectionContext = collectionContext else { return nil }
        var cell: UICollectionViewCell? = nil
        if let nibName = nibName {
            cell = collectionContext.sectionController(
                self,
                dequeueReusableCellWithNibName: nibName,
                bundle: bundle,
                at: index)
        } else if let identifier = identifier {
            cell = collectionContext.sectionController(
                self,
                dequeueReusableCellFromStoryboardWithIdentifier: identifier,
                at: index)
        } else if let cellClass = cellClass {
            cell = collectionContext.sectionController(
                self,
                dequeueReusableCellOfClass: cellClass,
                at: index)
        }
        guard let dequeuedCell = cell, let item = item else { return nil }
        configureClosure(item, dequeuedCell)
        return dequeuedCell
    }
    
    public override func didUpdate(to object: AnyListDiffable) {
        item = object
    }
    
    public override func didSelectItem(at index: Int) {
        guard let item = item else { return }
        selectionDelegate?.didSelect(self, with: item)
    }
    
    public override func didDeselectItem(at index: Int) {
        guard let item = item else { return }
        selectionDelegate?.didDeselect(self, with: item)
    }
    
    // MARK: - Private properties
    private var item: AnyListDiffable?
    private var nibName: String?
    private var bundle: Bundle?
    private var identifier: String?
    private var cellClass: AnyClass?
    private var configureClosure: ListSingleSectionCellConfigureClosure
    private var sizeClosure: ListSingleSectionCellSizeClosure
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
