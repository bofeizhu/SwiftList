//
//  ListMoveIndexPath.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 An object representing a move between indexes.
 */
struct ListMoveIndexPath: Hashable {
    /**
     An index path in the old collection.
     */
    let from: IndexPath
    
    /**
     An index path in the new collection.
     */
    let to: IndexPath
    
    init(from: IndexPath, to: IndexPath) {
        self.from = from
        self.to = to
    }
}

extension ListMoveIndexPath: Comparable {
    static func == (lhs: ListMoveIndexPath, rhs: ListMoveIndexPath) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    static func < (lhs: ListMoveIndexPath, rhs: ListMoveIndexPath) -> Bool {
        return lhs.from < rhs.from
    }
}
