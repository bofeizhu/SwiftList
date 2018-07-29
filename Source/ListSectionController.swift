//
//  ListSectionController.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/13/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The base class for section controllers used in a list. This class is intended to be subclassed.
open class ListSectionController {
    
    /// The view controller housing the adapter that created this section controller.
    ///
    /// - Note: Use this view controller to push, pop, present, or do other custom transitions.
    /// - Warning: It is considered very bad practice to cast this to a known view controller and
    ///     call methods on it other than for navigations and transitions.
    public internal(set) weak var viewController: UIViewController?
    
    /// A context object for interacting with the collection. Use this property for accessing the
    /// collection size, dequeuing cells, reloading, inserting, deleting, etc.
    public internal(set) weak var collectionContext: ListCollectionContext?
    
    /// Returns the section within the list for this section controller.
    ///
    /// - Note: This value also relates to the section within a `UICollectionView` that this
    ///     section controller's cells belong. It also relates to the `IndexPath.section` value for
    ///     individual cells within the collection view.
    public internal(set) var section: Int?
    
    /// Returns the number of items in the section.
    ///
    /// - Note: The count returned is used to drive the number of cells displayed for this section
    ///     controller. The default implementation returns 1.
    open var numberOfItems: Int {
        return 1
    }
    
    /// Returns `true` if the section controller is the first section in the list, `false`
    /// otherwise.
    public internal(set) var isFirstSection: Bool = false
    
    /// Returns `true` if the section controller is the last section in the list, `false` otherwise.
    public internal(set) var isLastSection: Bool = false
    
    
    /// The margins used to lay out content in the section controller.
    /// - SeeAlso: `UICollectionViewFlowLayout.sectionInset`
    public var inset: UIEdgeInsets = UIEdgeInsets.zero
    
    
    /// The minimum spacing to use between rows of items.
    /// - SeeAlso: `UICollectionViewFlowLayout.minimumLineSpacing`
    public var minimumLineSpacing: CGFloat = 0.0
    
    
    /// The minimum spacing to use between items in the same row.
    /// - SeeAlso: `UICollectionViewFlowLayout.minimumInteritemSpacing`
    public var minimumInteritemSpacing: CGFloat = 0.0
    
    /// The supplementary view source for the section controller.
    public weak var supplementaryViewSource: ListSupplementaryViewSource?
    
    /// An object that handles display events for the section controller.
    public weak var  displayDelegate: ListDisplayDelegate?
    
    /// An object that handles working range events for the section controller.
    public weak var workingRangeDelegate: ListWorkingRangeDelegate?
    
    /// An object that handles scroll events for the section controller.
    public weak var scrollDelegate: ListScrollDelegate?
    
    /// An object that handles transition events for the section controller.
    public weak var transitionDelegate: ListTransitionDelegate?
    
    public init() {
        if let context = dispatchQueueContextStack().last {
            viewController =  context.viewController
            collectionContext = context.collectionContext
        }
        
        if viewController == nil || collectionContext == nil {
            listLogDebug("Warning: Creating \(type(of: self)) outside of" +
                " `ListAdapterDataSource.listAdapter(_:sectionControllerForObject:)`." +
                " Collection context and view controller will be set later.")
        }
    }
    
    /// The specific size for the item at the specified index.
    ///
    /// - Parameter index: The row index of the item.
    /// - Returns: The size for the item at index.
    /// - Note: The returned size is not guaranteed to be used. The implementation may query
    ///     sections for their layout information at will, or use its own layout metrics.
    ///     For example, consider a dynamic-text sized list versus a fixed height-and-width grid.
    ///     The former will ask each section for a size, and the latter will likely not. The default
    ///     implementation returns size zero. **Calling super is not required.**
    open func sizeForItem(at index: Int) -> CGSize? {
        return nil
    }
    
    /// Return a dequeued cell for a given index.
    ///
    /// - Parameter index: The index of the requested row.
    /// - Returns: A configured `UICollectionViewCell` subclass.
    /// - Note: This is your opportunity to do any cell setup and configuration. The infrastructure
    ///     requests a cell when it will be used on screen. You should never allocate new cells in
    ///     this method, instead use the provided adapter to call one of the dequeue methods on the
    ///     `ListCollectionContext`. The default implementation will assert. **You must override
    ///     this method without calling super.**
    open func cellForItem(at index: Int) -> UICollectionViewCell? {
        assertionFailure("Section controller \(type(of: self)) must override \(#function)" )
        return nil
    }
    
    /// Updates the section controller to a new object.
    ///
    /// - Parameter object: The object mapped to this section controller.
    /// - Note: When this method is called, all available contexts and configurations have been set
    ///     for the section controller. This method will only be called when the object instance has
    ///     changed, including from `nil` or a previous object. **Calling super is not required.**
    open func didUpdate(to object: AnyListDiffable) {}
    
    /// Tells the section controller that the cell at the specified index path was selected.
    ///
    /// - Parameter index: The index of the selected cell.
    /// - Note: The default implementation does nothing. **Calling super is not required.**
    open func didSelectItem(at index: Int) {}
    
    /// Tells the section controller that the cell at the specified index path was deselected.
    ///
    /// - Parameter index: The index of the deselected cell.
    /// - Note: The default implementation does nothing. **Calling super is not required.**
    open func didDeselectItem(at index: Int) {}
    
    /// Tells the section controller that the cell at the specified index path was highlighted.
    ///
    /// - Parameter index: The index of the highlighted cell.
    /// - Note: The default implementation does nothing. **Calling super is not required.**
    open func didHighlightItem(at index: Int) {}
    
    /// Tells the section controller that the cell at the specified index path was unhighlighted.
    ///
    /// - Parameter index: The index of the unhighlighted cell.
    /// - Note: The default implementation does nothing. **Calling super is not required.**
    open func didUnhighlightItem(at index: Int) {}
    
    /// Identifies whether an object can be moved through interactive reordering.
    ///
    /// - Parameter index: The index of the cell to be moved.
    /// - Returns: `true` if the cell can be moved, `false` otherwise.
    /// - Note: Interactive reordering is supported both for items within a single section, as well
    ///     as for reordering sections themselves when sections contain only one item. The default
    //      implementation returns false.
    open func canMoveItem(at index: Int) -> Bool {
        return false
    }
    
    /// Notifies the section that a list object should move within a section as the result of
    /// interactive reordering.
    ///
    /// - Parameters:
    ///   - sourceItemIndex: The starting index of the object.
    ///   - destinationItemIndex: The ending index of the object.
    /// - Returns: `true` if the object can be moved, `false` otherwise.
    /// - Note: This method must be implemented if interactive reordering is enabled.
    public func canMoveItem(at sourceItemIndex: Int, to destinationItemIndex: Int) -> Bool {
        return canMoveItem(at: sourceItemIndex)
    }
    
    /// Notifies the section that a list object should move within a section as the result of
    /// interactive reordering.
    ///
    /// - Parameters:
    ///   - index: The starting index of the object.
    ///   - newIndex: The ending index of the object.
    /// - Note: This method must be implemented if interactive reordering is enabled.
    open func moveObject(from index: Int, to newIndex: Int) {
        assertionFailure("Section controller \(type(of: self)) must override \(#function)" +
            " if interactive reordering is enabled.")
    }
}

extension ListSectionController: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    public static func == (lhs: ListSectionController, rhs: ListSectionController) -> Bool {
        return lhs === rhs
    }
}

// MARK: Section Controller DispatchQueue Context
class ListSectionControllerDispatchQueueContext {
    weak var viewController: UIViewController?
    weak var collectionContext: ListCollectionContext?
}

let ListSectionControllerDispatchQueueKey =
    DispatchSpecificKey<[ListSectionControllerDispatchQueueContext]>()

func dispatchQueueContextStack() -> [ListSectionControllerDispatchQueueContext] {
    dispatchPrecondition(condition: .onQueue(.main))
    if let stack = DispatchQueue.main.getSpecific(key: ListSectionControllerDispatchQueueKey) {
        return stack
    }
    let stack: [ListSectionControllerDispatchQueueContext] = []
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
    return stack
}

func ListSectionControllerPushDispatchQueueContext(
    viewController: UIViewController?,
    collectionContext: ListCollectionContext?) {
    let context = ListSectionControllerDispatchQueueContext()
    context.viewController = viewController
    context.collectionContext = collectionContext
    var stack = dispatchQueueContextStack()
    stack.append(context)
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
}

func ListSectionControllerPopDispatchQueueContext() {
    var stack = dispatchQueueContextStack()
    guard stack.popLast() != nil else {
        assertionFailure("ListSectionController DispatchQueue stack is empty")
        return
    }
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
}
