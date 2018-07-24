//
//  ListAdapter.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/18/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// `ListAdapter` objects provide an abstraction for feeds of objects in a `UICollectionView`
/// by breaking each object into individual sections, called "section controllers".
/// These controllers (objects subclassing to `ListSectionController`) act as a data source and
/// delegate for each section.
///
/// Feed implementations must act as the data source for an `ListAdapter` in order to drive the
/// objects and section controllers in a collection view.
public final class ListAdapter: NSObject {
    // MARK: - Public Properties
    
    /// The view controller that houses the adapter.
    public private(set) weak var viewController: UIViewController?
    
    /// The collection view used with the adapter.
    ///
    /// - Note: Setting this property will automatically set isPrefetchingEnabled to `false`
    ///     for performance reasons.
    public weak var collectionView: UICollectionView? {
        willSet (newCollectionView) {
            dispatchPrecondition(condition: .onQueue(.main))
            
            guard collectionView !== newCollectionView ||
                  collectionView?.dataSource !== self else { return }
            
            // if collection view has been used by a different list adapter, treat it as if we were
            // using a new collection view this happens when embedding a `UICollectionView` inside a
            // `UICollectionViewCell` that is reused
            if let collectionView = collectionView {
                let collectionViewID = ObjectIdentifier(collectionView)
                ListAdapter.globalCollectionViewAdapterDict.removeValue(forKey: collectionViewID)
            }
            
            if let newCollectionView = newCollectionView {
                let newCollectionViewID = ObjectIdentifier(newCollectionView)
                if let weakBox = ListAdapter.globalCollectionViewAdapterDict[newCollectionViewID],
                    let oldAdapter = weakBox.listAdapter {
                    oldAdapter.collectionView = nil
                }
            }
            
            // dump old registered section controllers in the case that we are changing collection
            // views or setting for the first time
            registeredCellClasses = []
            registeredNibNames = []
            registeredSupplementaryViewIdentifiers = []
            registeredSupplementaryViewNibNames = []
            
            settingFirstCollectionView = collectionView == nil
        }
        
        didSet {
            guard let collectionView = collectionView else { return }
            
            let collectionViewID = ObjectIdentifier(collectionView)
            ListAdapter.globalCollectionViewAdapterDict[collectionViewID] = ListAdapterWeakBox(self)
            
            collectionView.dataSource = self
            collectionView.isPrefetchingEnabled = false
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.delegate = self
            
            // only construct
            if experiments.contains(.getCollectionViewAtUpdate) || settingFirstCollectionView {
                updateAfterPublicSettingsChange()
            }
        }
    }
    
    /// The object that acts as the data source for the adapter.
    public weak var dataSource: ListAdapterDataSource? {
        didSet {
            updateAfterPublicSettingsChange()
        }
    }
    
    /// The object that receives top-level events for section controllers.
    public weak var delegate: ListAdapterDelegate?
    
    /// The object that receives `UICollectionViewDelegate` events.
    ///
    /// - Note: This object *will not* receive `UIScrollViewDelegate` events. Instead use
    ///     scrollViewDelegate.
    public weak var collectionViewDelegate: UICollectionViewDelegate? {
        didSet {
            assert(
                !(collectionViewDelegate is UICollectionViewFlowLayout),
                "UICollectionViewDelegateFlowLayout conformance is automatically handled by" +
                    " ListAdapter.")
        }
    }
    
    /// The object that receives `UIScrollViewDelegate` events.
    public weak var scrollViewDelegate: UIScrollViewDelegate?
    
    /// The object that receives `IGListAdapterMoveDelegate` events resulting from interactive
    /// reordering of sections.
    public weak var moveDelegate: ListAdapterMoveDelegate?
    
    /// The updater for the adapter.
    public private(set) var updater: ListUpdatingDelegate
    
    /// An option set of experiments to conduct on the adapter.
    public var experiments: ListExperiment = .none
    
    /// All the objects currently driving the adapter.
    public var objects: [AnyListDiffable] {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.objects
    }
    
    /// An **unordered** array of the currently visible objects.
    public var visibleObjects: [AnyListDiffable] {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let collectionView = collectionView else { return [] }
        var visibleObjects: [AnyListDiffable] = []
        for cell in collectionView.visibleCells {
            guard let sectionController = sectionController(for: cell)
            else {
                assertionFailure("Section controller nil for cell \(cell)")
                continue
            }
            guard let section = section(for: sectionController),
                  let object = object(forSection: section)
            else {
                assertionFailure("Object not found for section controller \(sectionController)")
                continue
            }
            visibleObjects.append(object)
        }
        return visibleObjects
    }
    
    /// An **unordered** array of the currently visible section controllers.
    public var visibleSectionControllers: [ListSectionController] {
        dispatchPrecondition(condition: .onQueue(.main))
        if experiments.contains(.fasterVisibleSectionController) {
            return visibleSectionControllersFromDisplayHandler
        } else {
            return visibleSectionControllersFromLayoutAttributes
        }
    }
    
    // MARK: - Initializers
    
    /// Initializes a new `IGListAdapter` object.
    ///
    /// - Parameters:
    ///   - updater: An object that manages updates to the collection view.
    ///   - viewController: The view controller that will house the adapter.
    ///   - workingRangeSize: The number of objects before and after the viewport to consider within
    ///         the working range.
    /// - Note: The working range is the number of objects beyond the visible objects (plus and
    ///     minus) that should be notified when they are close to being visible. For instance, if
    ///     you have 3 objects on screen and a working range of 2, the previous and succeeding 2
    ///     objects will be notified that they are within the working range. As you scroll the list
    ///     the range is updated as objects enter and exit the working range.
    ///
    ///     To opt out of using the working range, use `init(updater:viewController:)` or provide a
    ///     working range of `0`.
    init(updater: ListUpdatingDelegate, viewController: UIViewController?, workingRangeSize: Int) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        self.updater = updater
        self.viewController = viewController
        workingRangeHandler = ListWorkingRangeHandler(workingRangeSize: workingRangeSize)
        
        super.init()
        ListDebugger.track(adapter: self)
    }
    
    /// Initializes a new `IGListAdapter` object with a working range of `0`.
    ///
    /// - Parameters:
    ///   - updater: An object that manages updates to the collection view.
    ///   - viewController: The view controller that will house the adapter.
    convenience init(updater: ListUpdatingDelegate, viewController: UIViewController?) {
        self.init(updater: updater, viewController: viewController, workingRangeSize: 0)
    }
    
    // MARK: - Internal Properties
    var sectionMap = ListSectionMap()
    var displayHandler = ListDisplayHandler()
    private(set) var workingRangeHandler: ListWorkingRangeHandler
    var emptyBackgroundView: UIView?
    
    // we need to special case interactive section moves that are moved to the last position
    var isLastInteractiveMoveToLastSectionIndex: Bool = false
    
    
    // When making object updates inside a batch update closure, delete operations must use the
    // section /before/ any moves take place. This includes when other objects are deleted or
    // inserted ahead of the section controller making the mutations. In order to account for this
    // we must track when the adapter is in the middle of an update closure as well as the section
    // controller mapping prior to the transition.
    //
    // Note that the previous section controller map is destroyed as soon as a transition is
    // finished so there is no dangling objects or section controllers.
    var isInUpdateClosure = false
    var previousSectionMap: ListSectionMap?
    
    // Since we only save the cell classes for debug. We will save them as `String` a.k.a.
    // `\(Class.self)`
    var registeredCellClasses: Set<String> = []
    var registeredNibNames: Set<String> = []
    var registeredSupplementaryViewIdentifiers: Set<String> = []
    var registeredSupplementaryViewNibNames: Set<String> = []
    
    // MARK: - Private Properties
    private var viewSectionControllerDict: [UICollectionReusableView: ListSectionController] = [:]
    private var queuedCompletionClosures: [ListQueuedCompletion]?
    private var settingFirstCollectionView = true
    private var collectionViewClosure: ListCollectionViewClosure {
        if experiments.contains(.getCollectionViewAtUpdate) {
            return { [weak self] in self?.collectionView }
        } else {
            weak var collectionView = self.collectionView
            return { collectionView }
        }
    }
    
    // A set of `ListAdapterUpdateListenerWeakBox`
    private var updateListeners: Set<ListAdapterUpdateListenerWeakBox> = []
    private var isDequeuingCell = false
    private var isSendingWorkingRangeDisplayUpdates = false
    
    // A dictionary from collectionView's ObjectIdentifier to a weak reference of listAdapter.
    private static var globalCollectionViewAdapterDict: [ObjectIdentifier: ListAdapterWeakBox] = [:]
    
    private var isItemCountZero: Bool {
        return sectionMap.isItemCountZero
    }
    
    private var visibleSectionControllersFromDisplayHandler: [ListSectionController] {
        return Array(displayHandler.visibleSections.keys)
    }
    private var visibleSectionControllersFromLayoutAttributes: [ListSectionController] {
        var visibleSectionControllers: Set<ListSectionController> = []
        guard let collectionView = collectionView else {
            preconditionFailure("Collection view is nil")
        }
        guard let attributesArray = collectionView.collectionViewLayout.layoutAttributesForElements(
                  in: collectionView.bounds) else { return [] }
        for attributes in attributesArray {
            guard let sectionController = self.sectionController(
                      forSection: attributes.indexPath.section)
            else {
                assertionFailure(
                    "Section controller nil for cell in section \(attributes.indexPath.section)")
                continue
            }
            visibleSectionControllers.insert(sectionController)
        }
        return Array(visibleSectionControllers)
    }
    
    // MARK: - Deinit
    deinit {
        sectionMap.reset()
    }
}

// MARK: - Scrolling
extension ListAdapter {
    /// Scrolls to the specified object in the list adapter.
    ///
    /// - Parameters:
    ///   - object: The object to which to scroll.
    ///   - elementKinds: The types of supplementary views in the section.
    ///   - scrollDirection: n option indicating the direction to scroll.
    ///   - scrollPosition: An option that specifies where the item should be positioned when
    ///         scrolling finishes.
    ///   - animated: A flag indicating if the scrolling should be animated.
    func scroll(
        to object: AnyListDiffable,
        withSupplementaryViewOfKinds elementKinds: [String],
        in scrollDirection: UICollectionViewScrollDirection,
        at scrollPosition: UICollectionViewScrollPosition,
        animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        guard let section = self.section(for: object),
              let collectionView = collectionView else { return }
        
        let layout = collectionView.collectionViewLayout
        
        // force layout before continuing
        // this method is typcially called before pushing a view controller
        // thus, before the layout process has actually happened
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        
        let firstIndexPath = IndexPath(item: 0, section: section)
        
        // collect the layout attributes for the cell and supplementary views for the first index
        // this will break if there are supplementary views beyond item 0
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        
        let itemCount = collectionView.numberOfItems(inSection: section)
        if itemCount > 0 {
            attributesArray = layoutAttributesForSupplementaryView(
                ofKinds: elementKinds,
                at: firstIndexPath)
            if itemCount > 1 {
                let lastIndexPath = IndexPath(item: itemCount - 1, section: section)
                if let lastAttributes = layoutAttributesForSupplementaryView(
                       ofKinds: elementKinds,
                       at: lastIndexPath).first {
                    attributesArray.append(lastAttributes)
                }
            }
        } else {
            for kind in elementKinds {
                if let supplementaryAttributes = layout.layoutAttributesForDecorationView(
                       ofKind: kind,
                       at: firstIndexPath) {
                    attributesArray.append(supplementaryAttributes)
                }
            }
        }
        
        var minOffset: CGFloat = 0.0
        var maxOffset: CGFloat = 0.0
        for attributes in attributesArray {
            let frame = attributes.frame
            var originMin: CGFloat = 0.0
            var endMax: CGFloat = 0.0
            switch scrollDirection {
            case .horizontal:
                originMin = frame.minX
                endMax = frame.maxX
            case .vertical:
                originMin = frame.minY
                endMax = frame.maxY
            }
            
            // find the minimum origin value of all the layout attributes
            if attributes == attributesArray.first || originMin < minOffset {
                minOffset = originMin
            }
            
            // find the maximum end value of all the layout attributes
            if attributes == attributesArray.first || endMax > maxOffset {
                maxOffset = endMax
            }
        }
        
        let midOffset = (minOffset + maxOffset) / 2.0
        let width = collectionView.bounds.size.width
        let height = collectionView.bounds.size.height
        let contentInset = collectionView.listContentInset
        var contentOffset = collectionView.contentOffset
        switch scrollDirection {
        case .horizontal:
            switch scrollPosition {
            case .right:
                contentOffset.x = maxOffset - width - contentInset.left
            case .centeredHorizontally:
                let inset = (contentInset.left - contentInset.right) / 2.0
                contentOffset.x = midOffset - width / 2.0 - inset
            default:
                contentOffset.x = minOffset - contentInset.left
            }
            let maxOffsetX = collectionView.contentSize.width - collectionView.frame.size.width +
                contentInset.right
            let minOffsetX = -contentInset.left
            contentOffset.x = min(contentOffset.x, maxOffsetX)
            contentOffset.x = max(contentOffset.x, minOffsetX)
        case .vertical:
            switch scrollPosition {
            case .bottom:
                contentOffset.y = maxOffset - height
            case .centeredVertically:
                let inset = (contentInset.top - contentInset.bottom) / 2.0
                contentOffset.y = midOffset - height / 2.0 - inset
            default:
                contentOffset.y = minOffset - contentInset.top
            }
            let maxOffsetY = collectionView.contentSize.height - collectionView.frame.size.height +
                contentInset.bottom
            let minOffsetY = -contentInset.top
            contentOffset.y = min(contentOffset.y, maxOffsetY)
            contentOffset.y = max(contentOffset.y, minOffsetY)
        }
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
}

// MARK: - Editing
extension ListAdapter {
    /// Perform an update from the previous state of the data source. This is analogous to calling
    /// `UICollectionView.performBatchUpdates(_:completion:)`.
    ///
    /// - Parameters:
    ///   - animated: A flag indicating if the transition should be animated.
    ///   - completion: The block to execute when the updates complete.
    public func performUpdates(animated: Bool, completion: ListUpdaterCompletion?) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard collectionView != nil,
              let dataSource = dataSource
        else {
            listLogDebug(
                "Warning: Your call to performUpdates(animated:completion:) is ignored as" +
                    " dataSource or collectionView haven't been set.")
            completion?(false)
            return
        }
        
        let fromObjects = sectionMap.objects
        var toObjectsClosure: ListToObjectClosure
        if experiments.contains(.deferredToObjectCreation) {
            toObjectsClosure = { [weak self] in
                guard let strongSelf = self else { return nil }
                return dataSource.objects(for: strongSelf)
            }
        } else {
            let newObjects = dataSource.objects(for: self)
            toObjectsClosure = { newObjects }
        }
        
        enterBatchUpdates()
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            fromObjects: fromObjects,
            toObjectsClosure: toObjectsClosure,
            animated: animated,
            objectTransitionClosure: { [weak self] (toObjects) in
                guard let strongSelf = self else { return }
                // temporarily capture the item map that we are transitioning from in case
                // there are any item deletes at the same
                strongSelf.previousSectionMap = strongSelf.sectionMap
                strongSelf.update(objects: toObjects, dataSource: dataSource)
            },
            completion: { [weak self] (finished) in
                // release the previous items
                guard let strongSelf = self else { return }
                strongSelf.previousSectionMap = nil
                strongSelf.didFinishUpdateOfType(.performUpdates, animated: animated)
                completion?(finished)
                strongSelf.exitBatchUpdates()
            })
    }
    
    /// Perform an immediate reload of the data in the data source, discarding the old objects.
    ///
    /// - Parameter completion: The block to execute when the reload completes.
    /// - Warning: Do not use this method to update without animations as it can be very expensive
    ///     to teardown and rebuild all section controllers. Use
    ///     `ListAdapter.performUpdates(animated:completion)` instead.
    public func reloadData(withCompletion completion: ListUpdaterCompletion?) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard collectionView != nil,
            let dataSource = dataSource
            else {
                listLogDebug(
                    "Warning: Your call to reloadData(withCompletion:) is ignored as" +
                    " dataSource or collectionView haven't been set.")
                completion?(false)
                return
        }
        
        let objects = dataSource.objects(for: self)
        
        #if DEBUG
        objects.checkDuplicateDiffIdentifier()
        #endif
        
        updater.reloadDataWith(
            collectionViewClosure: collectionViewClosure,
            reloadUpdateClosure: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.sectionMap.reset()
                strongSelf.update(objects: objects, dataSource: dataSource)
            },
            completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                strongSelf.didFinishUpdateOfType(.reloadData, animated: false)
                completion?(finished)
                strongSelf.exitBatchUpdates()
            })
    }
    
    /// Reload the list for only the specified objects.
    ///
    /// - Parameter objects: The objects to reload.
    public func reload(_ objects: [AnyListDiffable]) {
        dispatchPrecondition(condition: .onQueue(.main))
        let shouldUsePrevious = shouldUsePreviousSectionMap(usePreviousIfInUpdateClosure: true)
        var sections: IndexSet
        if shouldUsePrevious {
            sections = reloadSections(with: &previousSectionMap!, objects: objects)
        } else {
            sections = reloadSections(with: &sectionMap, objects: objects)
        }
        
        guard let collectionView = collectionView else {
            assertionFailure("Tried to reload the adapter without a collection view")
            return
        }
        updater.collectionView(collectionView, reloadSections: sections)
    }
    
    /// Adds a listener to the list adapter.
    ///
    /// - Parameter updateListener: The object conforming to the `ListAdapterUpdateListener`
    ///     protocol.
    public func add(_ updateListener: ListAdapterUpdateListener) {
        dispatchPrecondition(condition: .onQueue(.main))
        updateListeners.insert(ListAdapterUpdateListenerWeakBox(updateListener))
    }
    
    /// Removes a listener from the list adapter.
    ///
    /// - Parameter updateListener: The object conforming to the `IGListAdapterUpdateListener`
    ///     protocol.
    public func remove(_ updateListener: ListAdapterUpdateListener) {
        dispatchPrecondition(condition: .onQueue(.main))
        updateListeners.remove(ListAdapterUpdateListenerWeakBox(updateListener))
    }
}

// MARK: - List Items & Sections
extension ListAdapter {
    /// Query the section controller at a given section index.
    ///
    /// - Parameter section: A section in the list.
    /// - Returns: A section controller.
    public func sectionController(forSection section: Int) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.sectionController(forSection: section)
    }
    
    /// Returns the section controller for the specified object.
    ///
    /// - Parameter object: An object from the data source.
    /// - Returns: A section controller.
    public func sectionController(for object: AnyListDiffable) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.sectionController(for: object)
    }
    
    /// Returns the object corresponding to a section in the list.
    ///
    /// - Parameter section: A section in the list.
    /// - Returns: The object for the specified section.
    public func object(forSection section: Int) -> AnyListDiffable? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.object(forSection: section)
    }
    
    /// Returns the object corresponding to the specified section controller in the list.
    ///
    /// - Parameter sectionController: A section controller in the list.
    /// - Returns: The object for the specified section controller
    public func object(for sectionController: ListSectionController) -> AnyListDiffable? {
        dispatchPrecondition(condition: .onQueue(.main))
        if let section = sectionMap.section(for: sectionController) {
            return sectionMap.object(forSection: section)
        }
        return nil
    }
    
    /// Query the section index of a list.
    ///
    /// - Parameter sectionController: A section controller in the list.
    /// - Returns: The section index of the list if it exists, `nil` otherwise.
    public func section(for sectionController: ListSectionController) -> Int? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.section(for: sectionController)
    }
    
    /// Returns the section corresponding to the specified object in the list.
    ///
    /// - Parameter object: An object in the list.
    /// - Returns: The section index of the list if it exists, `nil` otherwise.
    public func section(for object: AnyListDiffable) -> Int? {
        dispatchPrecondition(condition: .onQueue(.main))
        return section(for: object)
    }
    
    /// An **unordered** array of the currently visible cells for a given object.
    ///
    /// - Parameter object: An object in the list
    /// - Returns: An array of collection view cells.
    public func visibleCells(for object: AnyListDiffable) -> [UICollectionViewCell] {
         dispatchPrecondition(condition: .onQueue(.main))
        guard let section = sectionMap.section(for: object),
              let collectionView = collectionView
        else { return [] }
        return collectionView.visibleCells.filter { cell in
            guard let indexPath = collectionView.indexPath(for: cell) else { return false }
            return indexPath.section == section
        }
    }
}

// MARK: - Layout
extension ListAdapter {
    /// Returns the size of a cell at the specified index path.
    ///
    /// - Parameter indexPath: The index path of the cell.
    /// - Returns: The size of the cell.
    public func sizeForItem(at indexPath: IndexPath) -> CGSize? {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let sectionController = self.sectionController(forSection: indexPath.section),
            let size = sectionController.sizeForItem(at: indexPath.section) else { return nil }
        return CGSize(width: max(size.width, 0.0), height: max(size.height, 0.0))
    }
    
    /// Returns the size of a supplementary view in the list at the specified index path.
    ///
    /// - Parameters:
    ///   - elementKind: The kind of supplementary view.
    ///   - indexPath: The index path of the supplementary view.
    /// - Returns: The size of the supplementary view.
    public func sizeForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> CGSize? {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let supplementaryViewSource = supplementaryViewSource(at: indexPath),
              supplementaryViewSource.supportedElementKinds.contains(elementKind),
              let size = supplementaryViewSource.sizeForSupplementaryView(
                  ofKind: elementKind,
                  at: indexPath.item)
        else { return nil }
        return CGSize(width: max(size.width, 0.0), height: max(size.height, 0.0))
    }
}

// MARK: - ListCollectionContext
extension ListAdapter: ListCollectionContext {
    public var containerSize: CGSize {
        guard let collectionView = collectionView else {
            preconditionFailure("Collection View is nil")
        }
        return collectionView.bounds.size
    }
    
    public var containerInset: UIEdgeInsets {
        guard let collectionView = collectionView else {
            preconditionFailure("Collection View is nil")
        }
        return collectionView.contentInset
    }
    
    public var adjustedContainerInset: UIEdgeInsets {
        guard let collectionView = collectionView else {
            preconditionFailure("Collection View is nil")
        }
        return collectionView.listContentInset
    }
    
    public var insetContainerSize: CGSize {
        guard let collectionView = collectionView else {
            preconditionFailure("Collection View is nil")
        }
        return UIEdgeInsetsInsetRect(
            collectionView.bounds,
            collectionView.listContentInset).size
    }
    
    public var scrollingTraits: ListCollectionScrollingTraits {
        guard let collectionView = collectionView else {
            preconditionFailure("Collection View is nil")
        }
        return ListCollectionScrollingTraits(
            isTracking: collectionView.isTracking,
            isDragging: collectionView.isDragging,
            isDecelerating: collectionView.isDecelerating)
    }
    
    public func containerSize(for sectionController: ListSectionController) -> CGSize {
        let inset = sectionController.inset
        return CGSize(
            width: containerSize.width - inset.left - inset.right,
            height: containerSize.height - inset.top - inset.bottom)
    }
    
    public func index(
        for cell: UICollectionViewCell,
        in sectionController: ListSectionController
    ) -> Int? {
        dispatchPrecondition(condition: .onQueue(.main))
        
        guard let collectionView = collectionView else {
            return nil
        }
        let indexPath = collectionView.indexPath(for: cell)
        assert(
            indexPath == nil || indexPath?.section == section(for: sectionController),
            "Requesting a cell from another section controller is not allowed.")
        return indexPath?.item
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        cellForItemAt index: Int
    ) -> UICollectionViewCell? {
        dispatchPrecondition(condition: .onQueue(.main))
        
        // if this is accessed while a cell is being dequeued or displaying working range elements,
        // just return nil
        if isDequeuingCell || isSendingWorkingRangeDisplayUpdates {
            return nil
        }
        guard let indexPath = indexPath(
                  for: sectionController,
                  at: index,
                  usePreviousIfInUpdateClosure: true),
              let collectionView = collectionView,
              indexPath.section < collectionView.numberOfSections,
              let cell = collectionView.cellForItem(at: indexPath),
              self.sectionController(for: cell) == sectionController else { return nil }
        // only return a cell if it belongs to the section controller
        // this association is created in collectionView.cellForItem(at:)
        return cell
    }
    
    public func visibleCells(
        for sectionController: ListSectionController
    ) -> [UICollectionViewCell] {
        guard let collectionView = collectionView,
              let section = self.section(for: sectionController) else { return [] }
        var cells: [UICollectionViewCell] = []
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            if collectionView.indexPath(for: cell)?.section == section {
                cells.append(cell)
            }
        }
        return cells
    }
    
    public func visibleIndexPaths(for sectionController: ListSectionController) -> [IndexPath] {
        guard let collectionView = collectionView,
              let section = section(for: sectionController) else { return [] }
        var indexPaths: [IndexPath] = []
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            if indexPath.section == section {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        deselectItemAt index: Int,
        animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        if let indexPath = indexPath(
               for: sectionController,
               at: index,
               usePreviousIfInUpdateClosure: false) {
            collectionView?.deselectItem(at: indexPath, animated: animated)
        }
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        selectItemAt index: Int,
        animated: Bool,
        scrollPosition: UICollectionViewScrollPosition) {
        dispatchPrecondition(condition: .onQueue(.main))
        if let indexPath = indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false) {
            collectionView?.selectItem(
                at: indexPath,
                animated: animated,
                scrollPosition: scrollPosition)
        }
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellOfClass cellClass: AnyClass,
        withReuseIdentifier identifier: String?,
        at index: Int
    ) -> UICollectionViewCell {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing cell of class \(cellClass) with reuseIdentifier" + (identifier ?? "") +
                    " from section controller \(sectionController) without a collection view at" +
                    " index \(index)")
        }
        guard let indexPath = self.indexPath(
                  for: sectionController,
                  at: index,
                  usePreviousIfInUpdateClosure: false)
        else {
            preconditionFailure(
                "No indexPath when dequeueing cell class \(cellClass) with reuseIdentifier" +
                    (identifier ?? "") + " from section controller \(sectionController) at" +
                    " \(index)")
        }
        let identifier = ListAdapter.reusableViewIdentifier(
            viewClass: cellClass, kind: nil, givenReuseIdentifier: identifier)
        if !registeredCellClasses.contains("\(cellClass.self)") {
            registeredCellClasses.insert("\(cellClass.self)")
            collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellOfClass cellClass: AnyClass,
        at index: Int
    ) -> UICollectionViewCell {
        return self.sectionController(
            sectionController,
            dequeueReusableCellOfClass: cellClass,
            withReuseIdentifier: nil,
            at: index)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellWithNibName nibName: String,
        bundle: Bundle?,
        at index: Int
    ) -> UICollectionViewCell {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        assert(!nibName.isEmpty, "Empty nib name")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing cell with nib name \(nibName) and bundle" +
                    " \(String(describing: bundle)) from section controller \(sectionController)" +
                    " without a collection view at index \(index)")
        }
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
        else {
            preconditionFailure(
                "No indexPath when dequeueing cell with nib name \(nibName) and bundle" +
                    " \(String(describing: bundle)) from section controller \(sectionController)" +
                    " at \(index)")
        }
        if !registeredNibNames.contains(nibName) {
            registeredNibNames.insert(nibName)
            let nib = UINib(nibName: nibName, bundle: bundle)
            collectionView.register(nib, forCellWithReuseIdentifier: nibName)
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableCellFromStoryboardWithIdentifier identifier: String,
        at index: Int
    ) -> UICollectionViewCell {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        assert(!identifier.isEmpty, "Empty identifier")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing cell with storyboard identifier: " + identifier + " from" +
                    " section controller \(sectionController) without a collection view at" +
                    " index \(index)")
        }
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
        else {
            preconditionFailure(
                "No indexPath when dequeueing cell with storyboard identifier: " + identifier +
                    " from section controller \(sectionController) without a collection view at" +
                    " index \(index)")
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        viewClass: AnyClass,
        at index: Int
    ) -> UICollectionReusableView {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing supplementary view of class \(viewClass) with element kind" +
                    elementKind + " from section controller \(sectionController)" +
                    " without a collection view at index \(index)")
        }
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
            else {
                preconditionFailure(
                    "No indexPath when dequeueing supplementary view of class \(viewClass) with" +
                        " element kind" + elementKind + " from section controller" +
                        " \(sectionController) at \(index)")
        }
        let identifier = ListAdapter.reusableViewIdentifier(
            viewClass: viewClass, kind: elementKind, givenReuseIdentifier: nil)
        if !registeredSupplementaryViewIdentifiers.contains(identifier) {
            registeredSupplementaryViewIdentifiers.insert(identifier)
            collectionView.register(
                viewClass,
                forSupplementaryViewOfKind: elementKind,
                withReuseIdentifier: identifier)
        }
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: identifier,
            for: indexPath)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewOfKind elementKind: String,
        nibName: String,
        bundle: Bundle?,
        at index: Int
    ) -> UICollectionReusableView {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        assert(!nibName.isEmpty, "Empty nib name")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing supplementary view with nib name \(nibName) and bundle" +
                    " \(String(describing: bundle)) from section controller \(sectionController)" +
                    " without a collection view at index \(index)")
        }
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
        else {
            preconditionFailure(
                "No indexPath when dequeueing supplementary view with nib name \(nibName)" +
                    " and bundle" + " \(String(describing: bundle)) from section controller" +
                    " \(sectionController) at \(index)")
        }
        if !registeredSupplementaryViewNibNames.contains(nibName) {
            registeredSupplementaryViewNibNames.insert(nibName)
            let nib = UINib(nibName: nibName, bundle: bundle)
            collectionView.register(
                nib,
                forSupplementaryViewOfKind: elementKind,
                withReuseIdentifier: nibName)
        }
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: nibName,
            for: indexPath)
    }
    
    public func sectionController(
        _ sectionController: ListSectionController,
        dequeueReusableSupplementaryViewFromStoryboardOfKind elementKind: String,
        withIdentifier identifier: String,
        at index: Int
    ) -> UICollectionReusableView {
        dispatchPrecondition(condition: .onQueue(.main))
        assert(index >= 0, "Negative index")
        assert(!identifier.isEmpty, "Empty identifier")
        guard let collectionView = collectionView
        else {
            preconditionFailure(
                "Dequeueing supplementary view with storyboard identifier: " + identifier +
                    " from section controller \(sectionController) without a collection view at" +
                    " index \(index)")
        }
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
        else {
            preconditionFailure(
                "No indexPath when dequeueing supplementary view with storyboard identifier: " +
                    identifier + " from section controller \(sectionController) without a" +
                    " collection view at index \(index)")
        }
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: identifier,
            for: indexPath)
    }
    
    public func invalidateLayoutFor(
        sectionController: ListSectionController,
        completion: ((Bool) -> Void)?) {
        guard let collectionView = collectionView else {
            assertionFailure("Cannot invalidate Layout when collection view is nil")
            return
        }
        guard let section = self.section(for: sectionController) else {
            assertionFailure("Cannot find section for section controller: \(sectionController)")
            return
        }
        let itemCount = collectionView.numberOfItems(inSection: section)
        var indexPaths: [IndexPath] = []
        for item in 0..<itemCount {
            indexPaths.append(IndexPath(item: item, section: section))
        }
        
        let layout = collectionView.collectionViewLayout
        // FIXME: UIKit Bug https://bugs.swift.org/browse/SR-7045
        let context = UICollectionViewLayoutInvalidationContext()
        context.invalidateItems(at: indexPaths)
        
        // do not call UICollectionView.performBatchUpdates(_:completion:) while already updating.
        // defer it until completed.
        deferClosureBetweenBatchUpdates { [weak collectionView = self.collectionView] in
            collectionView?.performBatchUpdates({
                layout.invalidateLayout(with: context)
            }, completion: completion)
        }
    }
    
    public func performBatchUpdates(
        _ updates: @escaping (ListBatchContext) -> Void,
        animated: Bool,
        completion: ((Bool) -> Void)?) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard viewController != nil else {
            assertionFailure("Performing batch updates without a collection view.")
            return
        }
        enterBatchUpdates()
        
        updater.performUpdateWith(
            collectionViewClosure: collectionViewClosure,
            animated: animated,
            itemUpdates: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isInUpdateClosure = true
                // the adapter acts as the batch context with its API stripped to just the
                // `ListBatchContext` protocol
                updates(strongSelf)
                strongSelf.isInUpdateClosure = false
            }, completion: { [weak self] (finished) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updateBackgroundView(isHidden: strongSelf.isItemCountZero)
                strongSelf.didFinishUpdateOfType(.itemUpdates, animated: animated)
                completion?(finished)
                strongSelf.exitBatchUpdates()
            })
    }
    
    public func scroll(
        to sectionController: ListSectionController,
        at index: Int,
        scrollPosition: UICollectionViewScrollPosition,
        animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let indexPath = self.indexPath(
            for: sectionController,
            at: index,
            usePreviousIfInUpdateClosure: false)
        else {
            assertionFailure(
                "No indexPath from section controller \(sectionController) at \(index)")
            return
        }
        collectionView?.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
}

// MARK: - ListBatchContext
extension ListAdapter: ListBatchContext {
    
}

// MARK: - Private APIs
extension ListAdapter {
    func map(view: UICollectionReusableView, to sectionController: ListSectionController) {
        dispatchPrecondition(condition: .onQueue(.main))
        viewSectionControllerDict[view] = sectionController
    }
    
    func indexPaths(
        from sectionController: ListSectionController,
        at indices: IndexSet,
        usePreviousIfInUpdateClosure: Bool
    ) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        let map = sectionMap(usePreviousIfInUpdateClosure: usePreviousIfInUpdateClosure)
        if let section = map.section(for: sectionController) {
            for index in indices {
                indexPaths.append(IndexPath(item: index, section: section))
            }
        }
        return indexPaths
    }
    
    func indexPath(
        for sectionController: ListSectionController,
        at index: Int,
        usePreviousIfInUpdateClosure: Bool
    ) -> IndexPath? {
        let map = sectionMap(usePreviousIfInUpdateClosure: usePreviousIfInUpdateClosure)
        if let section = map.section(for: sectionController) {
            return IndexPath(item: index, section: section)
        }
        return nil
    }
    
    func sectionController(for view: UICollectionReusableView) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        return viewSectionControllerDict[view]
    }
    
    func removeSectionController(for view: UICollectionReusableView) {
        dispatchPrecondition(condition: .onQueue(.main))
        viewSectionControllerDict.removeValue(forKey: view)
    }
}

// MARK: - Private Helpers
private extension ListAdapter {
    // MARK: Init
    func updateAfterPublicSettingsChange() {
        guard collectionView != nil,
            let dataSource = dataSource else { return }
        let objects = dataSource.objects(for: self)
        
        #if DEBUG
        objects.checkDuplicateDiffIdentifier()
        #endif
        
        update(objects: objects, dataSource: dataSource)
    }
    
    // MARK: Editing
    func didFinishUpdateOfType(_ updateType: ListAdapterUpdateType, animated: Bool) {
        for listener in updateListeners {
            listener.updateListener?.listAdapter(
                self,
                didFinishUpdateOfType: updateType,
                animated: animated)
        }
    }
    
    func reloadSections(
        with sectionMap: inout ListSectionMap,
        objects: [AnyListDiffable]
    ) -> IndexSet {
        var sections: IndexSet = []
        for object in objects {
            // look up the item using the map's lookup function. might not be the same item
            guard let section = sectionMap.section(for: object) else { continue }
            sections.insert(section)
            
            // reverse lookup the item using the section. if the pointer has changed the trigger
            // update events and swap items
            guard object != sectionMap.object(forSection: section) else { continue }
            sectionMap.update(object)
            sectionMap.sectionController(forSection: section)?.didUpdate(to: object)
        }
        return sections
    }
    
    // MARK: List Items & Sections
    func sectionMap(usePreviousIfInUpdateClosure: Bool) -> ListSectionMap {
        if usePreviousIfInUpdateClosure,
           isInUpdateClosure,
           let previousSectionMap = previousSectionMap {
            return previousSectionMap
        } else {
            return sectionMap
        }
    }
    
    func shouldUsePreviousSectionMap(usePreviousIfInUpdateClosure: Bool) -> Bool {
        if usePreviousIfInUpdateClosure,
            isInUpdateClosure,
            previousSectionMap != nil {
            return true
        } else {
            return false
        }
    }
    
    func supplementaryViewSource(at indexPath: IndexPath) -> ListSupplementaryViewSource? {
        guard let sectionController = sectionController(forSection: indexPath.section) else {
            return nil
        }
        return sectionController.supplementaryViewSource
    }
    
    // MARK: Layout
    func layoutAttributesForSupplementaryView(
        ofKinds elementKinds: [String],
        at indexPath: IndexPath
    ) -> [UICollectionViewLayoutAttributes] {
        var attributes: [UICollectionViewLayoutAttributes] = []
        guard let layout = collectionView?.collectionViewLayout else {
            assertionFailure("CollectionView has no layout")
            return attributes
        }
        if let cellAttributes = layout.layoutAttributesForItem(at: indexPath) {
            attributes.append(cellAttributes)
        }
        
        for kind in elementKinds {
            if let supplementaryAttributes = layout.layoutAttributesForSupplementaryView(
                ofKind: kind,
                at: indexPath) {
                attributes.append(supplementaryAttributes)
            }
        }
        
        return attributes
    }
    
    // MARK: Update
    
    // this method is what updates the "source of truth"
    // this should only be called just before the collection view is updated
    func update(objects: [AnyListDiffable], dataSource: ListAdapterDataSource) {
        #if DEBUG
        for object in objects {
            assert(
                object == object,
                "Object instance \(object) not equal to itself. This will break infra map tables.")
        }
        #endif
        
        var sectionControllers: [ListSectionController] = []
        var validObjects: [AnyListDiffable] = []
        
        // collect items that have changed since the last update by their diffableIdentifier
        var updatedObjectsDict: [AnyHashable: AnyListDiffable] = [:]
        
        // push the view controller and collection context into a local thread container so they are
        // available on init for `ListSectionController` subclasses after calling super.init()
        ListSectionControllerPushDispatchQueueContext(
            viewController: viewController,
            collectionContext: self)
        
        for object in objects {
            // infra checks to see if a controller exists
            var optionalSectionController = sectionMap.sectionController(for: object)
            
            // if not, query the data source for a new one
            if optionalSectionController == nil {
                optionalSectionController = dataSource.listAdapter(
                    self,
                    sectionControllerFor: object)
            }
            
            guard let sectionController = optionalSectionController else {
                listLogDebug(
                    "WARNING: Ignoring nil section controller returned by data source" +
                    " \(dataSource) for object \(object).")
                continue
            }
            
            // in case the section controller was created outside of
            // listAdapter(_:sectionControllerForObject:)
            sectionController.collectionContext = self
            sectionController.viewController = viewController
            
            // check if the item has changed instances or is new
            if let oldSection = sectionMap.section(for: object),
                sectionMap.object(forSection: oldSection) != object {
                updatedObjectsDict[object.diffIdentifier] = object
            }
            
            sectionControllers.append(sectionController)
            validObjects.append(object)
        }
        
        #if DEBUG
        assert(
            Set(sectionControllers).count == sectionControllers.count,
            "Section controllers array is not filled with unique objects; section controllers are" +
            " being reused")
        #endif
        
        // clear the view controller and collection context
        ListSectionControllerPopDispatchQueueContext()
        
        sectionMap.update(objects: validObjects, withSectionControllers: sectionControllers)
        
        // now that the maps have been created and contexts are assigned, we consider the section
        // controllers "fully loaded"
        for object in objects {
            sectionMap.sectionController(for: object)?.didUpdate(to: object)
        }
        
        var itemCount = 0
        for sectionController in sectionControllers {
            itemCount += sectionController.numberOfItems
        }
        
        updateBackgroundView(isHidden: itemCount > 0)
    }
    
    func deferClosureBetweenBatchUpdates(_ closure: @escaping ListQueuedCompletion) {
        dispatchPrecondition(condition: .onQueue(.main))
        if queuedCompletionClosures == nil {
            closure()
        } else {
            queuedCompletionClosures?.append(closure)
        }
    }
    
    func enterBatchUpdates() {
        queuedCompletionClosures = []
    }
    
    func exitBatchUpdates() {
        guard let closures = queuedCompletionClosures else { return }
        queuedCompletionClosures = nil
        for closure in closures {
            closure()
        }
    }
    
    func updateBackgroundView(isHidden: Bool) {
        if isInUpdateClosure {
            // will be called again when update closure completes
            return
        }
        
        let backgroundView = dataSource?.emptyBackgroundView(for: self)
        // don't do anything if the client is using the same view
        if backgroundView != collectionView?.backgroundView {
            // collection view will just stack the background views underneath each other if we do
            // not remove the previous one first. also fine if it is nil
            collectionView?.backgroundView?.removeFromSuperview()
            collectionView?.backgroundView = backgroundView
        }
        collectionView?.backgroundView?.isHidden = isHidden
    }
}

// MARK: - UICollectionViewDataSource
extension ListAdapter: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionMap.objects.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        guard let sectionController = sectionController(forSection: section) else {
            preconditionFailure("nil section controller for section \(section)." +
                " Check your diffIdentifier and == implementations.")
        }
        let numberOfItems = sectionController.numberOfItems
        guard numberOfItems >= 0 else {
            preconditionFailure("Cannot return negative number of items \(numberOfItems) for" +
                " section controller \(sectionController)" )
        }
        return numberOfItems
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionController = sectionController(forSection: indexPath.section) else {
            preconditionFailure("nil section controller for section \(indexPath.section)." +
                " Check your diffIdentifier and == implementations.")
        }
        // flag that a cell is being dequeued in case it tries to access a cell in the process
        isDequeuingCell = true
        guard let cell = sectionController.cellForItem(at: indexPath.item) else {
            preconditionFailure("Returned a nil cell at indexPath \(indexPath) from" +
                " section controller: \(sectionController)")
        }
        isDequeuingCell = false
        
        // associate the section controller with the cell so that we know which section controller
        // is using it
        map(view: cell, to: sectionController)
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension ListAdapter: UIScrollViewDelegate {
    
}

// MARK: - UICollectionViewDelegate
extension ListAdapter: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ListAdapter: UICollectionViewDelegateFlowLayout {
    
}

// MARK: - Class Methods
extension ListAdapter {
    static func reusableViewIdentifier(
        viewClass: AnyClass,
        kind: String?,
        givenReuseIdentifier: String?
    ) -> String {
        return (kind ?? "") + (givenReuseIdentifier ?? "") + "\(viewClass.self)"
    }
}

/// A completion closure to execute when the list updates are completed.
///
/// - Parameter finished: Specifies whether or not the update animations completed successfully.
public typealias ListUpdaterCompletion = (_ finished: Bool) -> Void

public typealias ListQueuedCompletion = () -> Void
