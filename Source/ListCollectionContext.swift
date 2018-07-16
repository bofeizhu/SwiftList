//
//  ListCollectionContext.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/12/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The collection context provides limited access to the collection-related information
/// that section controllers need for operations like sizing, dequeuing cells,
/// inserting, deleting, reloading, etc.
protocol ListCollectionContext: AnyObject {
    
    /// The size of the collection view. You can use this for sizing cells.
    var containerSize: CGSize { get }
    
    /// The content insets of the collection view. You can use this for sizing cells.
    var containerInset: UIEdgeInsets { get }
    
    /// The adjusted content insets of the collection view.
    /// Equivalent to containerInset under iOS 11.
    var adjustedContainerInset: UIEdgeInsets { get }
    
    /// The size of the collection view with content insets applied.
    var insetContainerSize: CGSize { get }

    /// The current scrolling traits of the underlying collection view.
    var scrollingTraits: ListCollectionScrollingTraits { get }
    
    /// Returns size of the collection view relative to the section controller.
    ///
    /// - Parameter sectionController: The section controller requesting this information.
    /// - Returns: The size of the collection view minus the given section controller's insets.
    func containerSizeFor(sectionController: ListSectionController) -> CGSize
    
    /// Returns the index of the specified cell in the collection relative to
    /// the section controller.
    ///
    /// - Parameters:
    ///     - cell: An existing cell in the collection.
    ///     - sectionController: The section controller requesting this information.
    /// - Returns: The index of the cell or `nil` if it does not exist in the collection.
    func sectionControllerindex(for cell: UICollectionViewCell, in : ListSectionController) -> Int?
    
    /// Returns the cell in the collection at the specified index for the section controller.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - index: The index of the desired cell.
    /// - Returns: The collection view cell, or `nil` if not found.
    /// - Warning: This method may return `nil` if the cell is offscreen.
    func sectionController(
        _ sectionController: ListSectionController,
        cellForItemAt index: Int
    ) -> UICollectionViewCell?
    
    /// Returns the visible cells for the given section controller.
    ///
    /// - Parameter sectionController: The section controller requesting this information.
    /// - Returns: An array of visible cells, or an empty array if none are found.
    func visibleCells(for sectionController: ListSectionController) -> [UICollectionViewCell]
    
    /// Returns the visible paths for the given section controller.
    ///
    /// - Parameter sectionController: The section controller requesting this information.
    /// - Returns: An array of visible index paths, or an empty array if none are found.
    func visibleIndexPaths(for sectionController: ListSectionController) -> [IndexPath]
    
    /// Deselects a cell in the collection.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - index: The index of the item to deselect.
    ///     - animated: Pass `true` to animate the change, `false` otherwise.
    func sectionController(
        _ sectionController: ListSectionController,
        deselectItemAt index: Int,
        animated: Bool)
    
    /// Selects a cell in the collection.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - index: The index of the item to select.
    ///     - animated: Pass `true` to animate the change, `false` otherwise.
    ///     - scrollPosition: An option that specifies where the item should be positioned when
    ///         scrolling finishes.
    func sectionController(
        _ sectionController: ListSectionController,
        selectItemAt index: Int,
        animated: Bool,
        scrollPosition: UICollectionViewScrollPosition)
    
    /// Dequeues a cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - cellClass: The class of the cell you want to dequeue.
    ///     - identifier: A reuse identifier for the specified cell. This parameter may be `nil`.
    ///     - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the cell class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellOfClass cellClass: AnyClass,
        withReuseIdentifier identifier: String,
        at index: Int
    ) -> UICollectionViewCell
    
    /// Dequeues a cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - cellClass: The class of the cell you want to dequeue.
    ///     - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the cell class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellOfClass cellClass: AnyClass,
        at index: Int
    ) -> UICollectionViewCell
    
    /// Dequeues a cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - nib: The nib object containing the cell object. The nib file must contain only one
    ///         top-level object and that object must be of the type `UICollectionViewCell`.
    ///     - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the cell class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellWithNib nib: UINib,
        at index: Int
    ) -> UICollectionViewCell
    
    /// Dequeues a storyboard prototype cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - identifier: The identifier of the cell prototype in storyboard.
    ///     - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellFromStoryboardWithIdentifier identifier: UINib,
        at index: Int
    ) -> UICollectionViewCell
    
    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - elementKind: The kind of supplementary view.
    ///     - viewClass: The class of the supplementary view.
    ///     - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        class viewClass: AnyClass,
        at index: Int
    ) -> UICollectionReusableView
    
    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - elementKind: The kind of supplementary view.
    ///     - nib: The nib object containing the cell object. The nib file must contain only one
    ///         top-level object and that object must be of the type `UICollectionReusableView`.
    ///     - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        nib: UINib,
        at index: Int
    ) -> UICollectionReusableView
    
    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///     - sectionController: The section controller requesting this information.
    ///     - elementKind: The kind of supplementary view.
    ///     - identifier: The identifier of the supplementary view in storyboard.
    ///     - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewFromStoryboardOfKind elementKind: String,
        withIdentifier identifier: String,
        at index: Int
    ) -> UICollectionReusableView
    
    
}
