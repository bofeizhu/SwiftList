//
//  ListCollectionScrollingTraits.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/13/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The current scrolling traits of the underlying collection view.
/// The attributes are always equal to their corresponding properties on the underlying
/// collection view.
public struct ListCollectionScrollingTraits {
    /// `true` if user has touched. may not yet have started dragging.
    var isTracking: Bool
    /// `true` if user has started scrolling.
    /// this may require some time and or distance to move to initiate dragging
    var isDragging: Bool
    /// `true` if user isn't dragging (touch up) but scroll view is still moving.
    var isDecelerating: Bool
}
