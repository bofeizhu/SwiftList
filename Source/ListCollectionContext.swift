//
//  ListCollectionContext.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/12/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The collection context provides limited access to the collection-related information
/// that section controllers need for operations like sizing, dequeuing cells,
/// inserting, deleting, reloading, etc.
public protocol ListCollectionContext: AnyObject {
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
    func containerSize(for sectionController: ListSectionController) -> CGSize

    /// Returns the index of the specified cell in the collection relative to
    /// the section controller.
    ///
    /// - Parameters:
    ///   - cell: An existing cell in the collection.
    ///   - sectionController: The section controller requesting this information.
    /// - Returns: The index of the cell or `nil` if it does not exist in the collection.
    func index(for cell: UICollectionViewCell, in sectionController: ListSectionController) -> Int?

    /// Returns the cell in the collection at the specified index for the section controller.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - index: The index of the desired cell.
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
    ///   - sectionController: The section controller requesting this information.
    ///   - index: The index of the item to deselect.
    ///   - animated: Pass `true` to animate the change, `false` otherwise.
    func sectionController(
        _ sectionController: ListSectionController,
        deselectItemAt index: Int,
        animated: Bool)

    /// Selects a cell in the collection.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - index: The index of the item to select.
    ///   - animated: Pass `true` to animate the change, `false` otherwise.
    ///   - scrollPosition: An option that specifies where the item should be positioned when
    ///       scrolling finishes.
    func sectionController(
        _ sectionController: ListSectionController,
        selectItemAt index: Int,
        animated: Bool,
        scrollPosition: UICollectionView.ScrollPosition)

    /// Dequeues a cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - cellClass: The class of the cell you want to dequeue.
    ///   - identifier: A reuse identifier for the specified cell. This parameter may be `nil`.
    ///   - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the cell class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellOfClass cellClass: AnyClass,
        withReuseIdentifier identifier: String?,
        at index: Int
    ) -> UICollectionViewCell

    /// Dequeues a cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - cellClass: The class of the cell you want to dequeue.
    ///   - index: The index of the cell.
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
    ///   - sectionController: Thee section controller requesting this information.
    ///   - nibName: The name of the nib file.
    ///   - bundle: The bundle in which to search for the nib file. If `nil`, this method searches
    ///       the main bundle.
    ///   - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the cell class as the identifier.
    /// Dequeues a cell from the collection view reuse pool.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellWithNibName nibName: String,
        bundle: Bundle?,
        at index: Int
    ) -> UICollectionViewCell

    /// Dequeues a storyboard prototype cell from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - identifier: The identifier of the cell prototype in storyboard.
    ///   - index: The index of the cell.
    /// - Returns: A cell dequeued from the reuse pool or a newly created one.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellFromStoryboardWithIdentifier identifier: String,
        at index: Int
    ) -> UICollectionViewCell

    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - elementKind: The kind of supplementary view.
    ///   - viewClass: The class of the supplementary view.
    ///   - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        viewClass: AnyClass,
        at index: Int
    ) -> UICollectionReusableView

    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - elementKind: The kind of supplementary view.
    ///   - nibName: The name of the nib file.
    ///   - bundle: The bundle in which to search for the nib file. If `nil`, this method searches
    ///       the main bundle.
    ///   - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        nibName: String,
        bundle: Bundle?,
        at index: Int
    ) -> UICollectionReusableView

    /// Dequeues a supplementary view from the collection view reuse pool.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller requesting this information.
    ///   - elementKind: The kind of supplementary view.
    ///   - identifier: The identifier of the supplementary view in storyboard.
    ///   - index: The index of the supplementary view.
    /// - Returns: A supplementary view dequeued from the reuse pool or a newly created one.
    /// - Note: This method uses a string representation of the view class as the identifier.
    func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewFromStoryboardOfKind elementKind: String,
        withIdentifier identifier: String,
        at index: Int
    ) -> UICollectionReusableView

    /// Invalidate the backing `UICollectionViewLayout` for all items in the section controller.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller that needs invalidating.
    ///   - completion: An optional completion closure to execute when the updates are finished.
    /// - Note: This method can be wrapped in `UIView` animation APIs to control the duration
    ///     or perform without animations. This will end up calling
    ///     `performBatchUpdates(_:completion:)` internally, so invalidated changes may not be
    ///     reflected in the cells immediately.
    func invalidateLayoutFor(
        sectionController: ListSectionController,
        completion: ((Bool) -> Void)?)

    /// Batches and performs many cell-level updates in a single transaction.
    ///
    /// - Parameters:
    ///   - updates: A closure with a context parameter to make mutations.
    ///   - animated: A flag indicating if the transition should be animated.
    ///   - completion: An optional completion closure to execute when the updates are finished.
    /// - Note: You should make state changes that impact the number of items in your section
    ///     controller within the updates closure alongside changes on the context object.
    ///
    ///     Inside your section controllers, you may want to delete *and* insert into
    ///     the data source that backs your section controller.
    ///     For example:
    ///     ```
    ///     ```
    /// - Warning: You **must** perform data modifications **inside** the update closure. Updates
    ///     will not be performed synchronously, so you should make sure that your data source
    ///     changes only when necessary.
    func performBatchUpdates(
        _ updates: @escaping (ListBatchContext) -> Void,
        animated: Bool,
        completion: ((Bool) -> Void)?)

    /// Scrolls to the specified section controller in the list.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller.
    ///   - index: The index of the item in the section controller to which to scroll.
    ///   - scrollPosition: An option that specifies where the item should be positioned when
    ///       scrolling finishes.
    ///   - animated: A flag indicating if the scrolling should be animated.
    func scroll(
        to sectionController: ListSectionController,
        at index: Int,
        scrollPosition: UICollectionView.ScrollPosition,
        animated: Bool)
}
