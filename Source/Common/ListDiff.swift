//
//  ListDiff.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Used to track data stats while diffing.
struct ListEntry {
     /// The number of times the data occurs in the old array
    var oldCounter = 0
    /// The number of times the data occurs in the new array
    var newCounter = 0
    /// The indexes of the data in the old array
    var oldIndexes: [Int]
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    var updated = false
}

/// Track both the entry and algorithm index. Default the index to NSNotFound
struct ListRecord {
    var entry: ListEntry?
    var index: Int?
}

