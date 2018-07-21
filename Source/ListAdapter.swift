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
public final class ListAdapter {
    
    /// The view controller that houses the adapter.
    public weak var viewController: UIViewController?
    
    /// The collection view used with the adapter.
    ///
    /// - Note: Setting this property will automatically set isPrefetchingEnabled to `false`
    ///     for performance reasons.
    public weak var collectionView: UICollectionView?
    
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
    public var experiments: ListExperiment
    
    init(updater: ListUpdatingDelegate, viewController: UIViewController?, workingRangeSize: Int) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        self.updater = updater
        
    }
    
    // MARK: Private APIs
    var sectionMap = ListSectionMap()
    var displayHandler = ListDisplayHandler()
    var workingRangeHandler
}

/// A completion closure to execute when the list updates are completed.
///
/// - Parameter finished: Specifies whether or not the update animations completed successfully.
public typealias ListUpdaterCompletion = (_ finished: Bool) -> Void
