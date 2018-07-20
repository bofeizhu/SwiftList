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
}

/// A completion closure to execute when the list updates are completed.
///
/// - Parameter finished: Specifies whether or not the update animations completed successfully.
public typealias ListUpdaterCompletion = (_ finished: Bool) -> Void
