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
public struct ListMoveIndexPath: Hashable {
    /**
     An index path in the old collection.
     */
    public let from: IndexPath
    
    /**
     An index path in the new collection.
     */
    public let to: IndexPath
    
    init(from: IndexPath, to: IndexPath) {
        self.from = from
        self.to = to
    }
}

extension ListMoveIndexPath: Comparable {
    public static func == (lhs: ListMoveIndexPath, rhs: ListMoveIndexPath) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    public static func < (lhs: ListMoveIndexPath, rhs: ListMoveIndexPath) -> Bool {
        return lhs.from < rhs.from
    }
}
