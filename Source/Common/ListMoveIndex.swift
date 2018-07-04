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
public struct ListMoveIndex: Hashable {
    /**
     An index in the old collection.
     */
    public let from: Int
    
    /**
     An index in the new collection.
     */
    public let to: Int
    
    //MARK: Private API
    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }
}

extension ListMoveIndex: Comparable {
    public static func == (lhs: ListMoveIndex, rhs: ListMoveIndex) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    public static func < (lhs: ListMoveIndex, rhs: ListMoveIndex) -> Bool {
        return lhs.from < rhs.from
    }
}
