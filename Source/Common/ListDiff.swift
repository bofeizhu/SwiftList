//
//  ListDiff.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 An option for how to do comparisons between similar objects.
 */
enum ListDiffOption {
    /**
     Compare objects using pointer personality.
     */
    case ListDiffPointerPersonality
    
    /**
     Compare objects using `ListDiffable.isEqualToDiffableObject()`.
     */
    case IGListDiffEquality
}

/// Used to track data stats while diffing.
fileprivate struct ListEntry {
     /// The number of times the data occurs in the old array
    var oldCounter = 0
    /// The number of times the data occurs in the new array
    var newCounter = 0
    /// The indexes of the data in the old array
    var oldIndexes: [Int]
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    var updated = false
}

/// Track both the entry and algorithm index.
fileprivate struct ListRecord {
    fileprivate var entry: ListEntry?
    var index: Int?
}

/* fileprivate func listDiffing(returnIndexPaths: Bool, fromSection: Int, toSection: Int,
                             oldArray: [ListDiffable], newArray: [ListDiffable],
                             option: ListDiffOption) -> Any {
    let newCount = newArray.count
    let oldCount = oldArray.count
    
    var oldDict = [AnyHashable: Any]()
    var newDict = [AnyHashable: Any]()
    
    // if no new objects, everything from the oldArray is deleted
    // take a shortcut and just build a delete-everything result
    if newCount == 0 {
        if returnIndexPaths {
            
        }
    }
} */
