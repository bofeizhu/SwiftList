//
//  ListReloadIndexPath.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// An object with index path information for reloading an item during a batch update.
struct ListReloadIndexPath {
    
    /// The index path of the item before batch updates are applied.
    let from: IndexPath
    
    /// The index path of the item after batch updates are applied.
    let to: IndexPath
    
    /// Creates a new reload object.
    ///
    /// - Parameters:
    ///    - from: The index path of the item before batch updates.
    ///    - to: The index path of the item after batch updates.
    init(from: IndexPath, to: IndexPath) {
        self.from = from
        self.to = to
    }
}
