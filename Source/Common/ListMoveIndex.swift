//
//  ListMoveIndex.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 An object representing a move between indexes.
 */
struct ListMoveIndex: Hashable {
    /**
     An index in the old collection.
     */
    let from: Int
    
    /**
     An index in the new collection.
     */
    let to: Int
    
    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }
}

extension ListMoveIndex: Comparable {
    static func == (lhs: ListMoveIndex, rhs: ListMoveIndex) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    static func < (lhs: ListMoveIndex, rhs: ListMoveIndex) -> Bool {
        return lhs.from < rhs.from
    }
}
