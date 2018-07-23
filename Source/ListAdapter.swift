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
            if let collectionView = self.collectionView {
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
            guard let collectionView = self.collectionView else { return }
            
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
    
    // Since we only save the cell classes for debug. We will save them as `String`.
    var registeredCellClasses: Set<String> = []
    var registeredNibNames: Set<String> = []
    var registeredSupplementaryViewIdentifiers: Set<String> = []
    var registeredSupplementaryViewNibNames: Set<String> = []
    
    // MARK: - Private Properties
    private var viewSectionControllerDict: [UICollectionReusableView: ListSectionController] = [:]
    private var queuedCompletionClosures: [ListQueuedCompletion]?
    
    /// A set of `ListAdapterUpdateListener`
    ///
    /// - Warning: **Only insert ListAdapterUpdateListener.** Since this is a private property, we
    ///     skip building a type erasure for it, and use `AnyHashable` instead.
    private var updateListeners: Set<AnyHashable> = []
    private var isDequeuingCell = false
    private var isSendingWorkingRangeDisplayUpdates = false
    
    // A dictionary from collectionView's ObjectIdentifier to a weak reference of listAdapter.
    private static var globalCollectionViewAdapterDict: [ObjectIdentifier: ListAdapterWeakBox] = [:]
    
    private var isItemCountZero: Bool {
        return sectionMap.isItemCountZero
    }
    
    private var settingFirstCollectionView = true
    
    // MARK: - Deinit
    deinit {
        sectionMap.reset()
    }
}

// MARK: - Scrolling
extension ListAdapter {
    
}

// MARK: - Editing
extension ListAdapter {
    
}

// MARK: - List Items & Sections
extension ListAdapter {
    
    /// Query the section controller at a given section index.
    ///
    /// - Parameter section: A section in the list.
    /// - Returns: A section controller.
    public func sectionController(for section: Int) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.sectionController(for: section)
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
    public func object(for section: Int) -> AnyListDiffable? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.object(for: section)
    }
    
    /// Returns the object corresponding to the specified section controller in the list.
    ///
    /// - Parameter sectionController: A section controller in the list.
    /// - Returns: The object for the specified section controller
    public func object(for sectionController: ListSectionController) -> AnyListDiffable? {
        dispatchPrecondition(condition: .onQueue(.main))
        if let section = sectionMap.section(for: sectionController) {
            return sectionMap.object(for: section)
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
}

// MARK: - Layout
extension ListAdapter {
    
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
            preconditionFailure("Collection View is nil")
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
    }
    
    public func visibleCells(for sectionController: ListSectionController) -> [UICollectionViewCell] {
        <#code#>
    }
    
    public func visibleIndexPaths(for sectionController: ListSectionController) -> [IndexPath] {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, deselectItemAt index: Int, animated: Bool) {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, selectItemAt index: Int, animated: Bool, scrollPosition: UICollectionViewScrollPosition) {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableCellOfClass cellClass: AnyClass, withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableCellOfClass cellClass: AnyClass, at index: Int) -> UICollectionViewCell {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableCellWithNib nib: UINib, at index: Int) -> UICollectionViewCell {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableCellFromStoryboardWithIdentifier identifier: UINib, at index: Int) -> UICollectionViewCell {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableSupplementaryViewOfKind elementKind: String, class viewClass: AnyClass, at index: Int) -> UICollectionReusableView {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableSupplementaryViewOfKind elementKind: String, nib: UINib, at index: Int) -> UICollectionReusableView {
        <#code#>
    }
    
    public func sectionController(_ sectionController: ListSectionController, dequeueReusableSupplementaryViewFromStoryboardOfKind elementKind: String, withIdentifier identifier: String, at index: Int) -> UICollectionReusableView {
        <#code#>
    }
    
    public func invalidateLayoutFor(sectionController: ListSectionController, completion: ((Bool) -> Void)?) {
        <#code#>
    }
    
    public func performBatchUpdates(_ updates: (ListBatchContext) -> Void, animated: Bool, completion: ((Bool) -> Void)?) {
        <#code#>
    }
    
    public func scroll(to sectionController: ListSectionController, at index: Int, scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        <#code#>
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
        indices: IndexSet,
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
        from sectionController: ListSectionController,
        index: Int,
        usePreviousIfInUpdateClosure: Bool
    ) -> IndexPath? {
        let map = sectionMap(usePreviousIfInUpdateClosure: usePreviousIfInUpdateClosure)
        if let section = map.section(for: sectionController) {
            return IndexPath(item: index, section: section)
        }
        return nil
    }
}

// MARK: - Private Helpers
private extension ListAdapter {
    func collectionViewClosure() -> ListCollectionViewClosure {
        if experiments.contains(.getCollectionViewAtUpdate) {
            return { [weak self] in self?.collectionView }
        } else {
            weak var collectionView = self.collectionView
            return { collectionView }
        }
    }
    
    func updateAfterPublicSettingsChange() {
        guard collectionView != nil,
              let dataSource = dataSource else { return }
        let objects = dataSource.objects(for: self)
        
        #if DEBUG
        objects.hasDuplicateHashValue()
        #endif
        
        update(objects: objects, dataSource: dataSource)
    }
    
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
               sectionMap.object(for: oldSection) != object {
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
    
    func sectionMap(usePreviousIfInUpdateClosure: Bool) -> ListSectionMap {
        if usePreviousIfInUpdateClosure,
           isInUpdateClosure,
           let previousSectionMap = self.previousSectionMap {
            return previousSectionMap
        } else {
            return sectionMap
        }
    }
    
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
}

// MARK: - UICollectionViewDataSource
extension ListAdapter: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionMap.objects.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        guard let sectionController = sectionController(for: section) else {
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
        guard let sectionController = sectionController(for: indexPath.section) else {
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

/// A completion closure to execute when the list updates are completed.
///
/// - Parameter finished: Specifies whether or not the update animations completed successfully.
public typealias ListUpdaterCompletion = (_ finished: Bool) -> Void
public typealias ListQueuedCompletion = () -> Void

