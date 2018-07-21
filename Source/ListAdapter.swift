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
    
    /// The view controller that houses the adapter.
    public private(set) weak var viewController: UIViewController?
    
    /// The collection view used with the adapter.
    ///
    /// - Note: Setting this property will automatically set isPrefetchingEnabled to `false`
    ///     for performance reasons.
    public weak var collectionView: UICollectionView? {
        willSet (newCollectionView) {
            dispatchPrecondition(condition: .onQueue(.main))
            
            
        }
    }
    
    /// The object that acts as the data source for the adapter.
    public weak var dataSource: ListAdapterDataSource?
    
    /// The object that receives top-level events for section controllers.
    public weak var delegate: ListAdapterDelegate?
    
    /// The object that receives `UICollectionViewDelegate` events.
    ///
    /// - Note: This object *will not* receive `UIScrollViewDelegate` events. Instead use
    ///     scrollViewDelegate.
    public weak var collectionViewDelegate: UICollectionViewDelegate?
    
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
    
    init(updater: ListUpdatingDelegate, viewController: UIViewController?, workingRangeSize: Int) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        self.updater = updater
        self.viewController = viewController
        workingRangeHandler = ListWorkingRangeHandler(workingRangeSize: workingRangeSize)
        
        ListDebugger.track(adapter: self)
    }
    
    convenience init(updater: ListUpdatingDelegate, viewController: UIViewController?) {
        self.init(updater: updater, viewController: viewController, workingRangeSize: 0)
    }
    
    /// Returns the object corresponding to a section in the list.
    ///
    /// - Parameter section: A section in the list.
    /// - Returns: The object for the specified section.
    public func object(for section: Int) -> AnyListDiffable? {
        dispatchPrecondition(condition: .onQueue(.main))
        return sectionMap.object(for: section)
    }
    
    /// Returns the section controller for the specified object.
    ///
    /// - Parameter object: An object from the data source.
    /// - Returns: A section controller.
    public func sectionController(for object: AnyListDiffable) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        
        return sectionMap.sectionController(for: object)
    }
    
    /// Query the section controller at a given section index.
    ///
    /// - Parameter section: A section in the list.
    /// - Returns: A section controller.
    public func sectionController(for section: Int) -> ListSectionController? {
        dispatchPrecondition(condition: .onQueue(.main))
        
        return sectionMap.sectionController(for: section)
    }
    
    // MARK: Private APIs
    var sectionMap = ListSectionMap()
    var displayHandler = ListDisplayHandler()
    private(set) var workingRangeHandler: ListWorkingRangeHandler
    var isLastInteractiveMoveToLastSectionIndex: Bool = false
    
    deinit {
        sectionMap.reset()
    }
    
    // MARK: Private
    private var viewSectionControllerDict: [UICollectionReusableView: ListSectionController] = [:]
    private var queuedCompletionClosures: [ListQueuedCompletion] = []
    
    /// A set of `ListAdapterUpdateListener`
    ///
    /// - Warning: **Only insert ListAdapterUpdateListener.** Since this is a private property, we
    ///     skip building a type erasure for it, and use `AnyHashable` instead.
    private var updateListeners: Set<AnyHashable> = []
}

/// A completion closure to execute when the list updates are completed.
///
/// - Parameter finished: Specifies whether or not the update animations completed successfully.
public typealias ListUpdaterCompletion = (_ finished: Bool) -> Void
public typealias ListQueuedCompletion = () -> Void

