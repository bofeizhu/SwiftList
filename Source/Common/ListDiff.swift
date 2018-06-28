//
//  ListDiff.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

enum ListDiffOption {
    /**
     Compare objects using `ObjectIdentifier`.
     */
    case ListDiffObjectIdentifier
    /**
     Compare objects using `hashValue`.
     */
    case ListDiffEquality
}

/// Used to track data stats while diffing.
fileprivate class ListEntry {
    /// The number of times the data occurs in the old array
    var oldCounter = 0
    /// The number of times the data occurs in the new array
    var newCounter = 0
    /// The indexes of the data in the old array
    var oldIndexes = [Int?]()
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    var updated = false
}

/// Track both the entry and algorithm index.
fileprivate class ListRecord {
    fileprivate var entry: ListEntry?
    var index: Int?
}

fileprivate extension Dictionary where Key == AnyListDiffable, Value == Any {
    mutating func addIndex(useIndexPath: Bool, section: Int, index: Int, object: AnyListDiffable) {
        var value: Any
        if useIndexPath {
            value = IndexPath(item: index, section: section)
        } else {
            value = index
        }
        self[object] = value
    }
    
    mutating func indexPathsAndPopulateMap(array: [AnyListDiffable], section: Int) -> [IndexPath] {
        var paths: [IndexPath] = []
        for (idx, obj) in array.enumerated() {
            let path = IndexPath(item: idx, section: section)
            paths.append(path)
            self[obj] = paths
        }
        return paths
    }
}

fileprivate func ListDiffing(returnIndexPaths: Bool, fromSection: Int, toSection: Int,
                             oldArray: [AnyListDiffable], newArray: [AnyListDiffable],
                             option: ListDiffOption, experiments: ListExperiment) -> Any {
    let newCount = newArray.count
    let oldCount = oldArray.count
    
    var oldDict: [AnyListDiffable: Any] = [:]
    var newDict: [AnyListDiffable: Any] = [:]
    
    // if no new objects, everything from the oldArray is deleted
    // take a shortcut and just build a delete-everything result
    if newCount == 0 {
        if returnIndexPaths {
            guard let oldIndexPathDict = oldDict as? [AnyListDiffable : IndexPath],
                let newIndexPathDict = newDict as? [AnyListDiffable : IndexPath] else {
                    preconditionFailure("Cannot downcast dictionary to dictionary of IndexPath")
            }
            return ListIndexPathResult(inserts: [],
                                       deletes: oldDict.indexPathsAndPopulateMap(array: oldArray, section: fromSection),
                                       updates: [], moves: [],
                                       oldIndexPathDict: oldIndexPathDict,
                                       newIndexPathDict: newIndexPathDict)
        } else {
            guard let oldIndexDict = oldDict as? [AnyListDiffable : Int],
                let newIndexDict = newDict as? [AnyListDiffable : Int] else {
                    preconditionFailure("Cannot downcast dictionary to dictionary of Int")
            }
            for (idx, obj) in oldArray.enumerated() {
                oldDict.addIndex(useIndexPath: returnIndexPaths, section: fromSection,
                                 index: idx, object: obj)
            }
            return ListIndexSetResult(inserts: IndexSet(), deletes: IndexSet(0..<oldCount),
                                      updates: IndexSet(), moves: [],
                                      oldIndexDict: oldIndexDict,
                                      newIndexDict: newIndexDict)
        }
    }
    
    // if no old objects, everything from the newArray is inserted
    // take a shortcut and just build an insert-everything result
    if oldCount == 0 {
        if returnIndexPaths {
            guard let oldIndexPathDict = oldDict as? [AnyListDiffable : IndexPath],
                let newIndexPathDict = newDict as? [AnyListDiffable : IndexPath] else {
                    preconditionFailure("Cannot downcast dictionary to dictionary of IndexPath")
            }
            return ListIndexPathResult(inserts: newDict.indexPathsAndPopulateMap(array: newArray, section: toSection),
                                       deletes: [], updates: [], moves: [],
                                       oldIndexPathDict: oldIndexPathDict,
                                       newIndexPathDict: newIndexPathDict)
        } else {
            guard let oldIndexDict = oldDict as? [AnyListDiffable : Int],
                let newIndexDict = newDict as? [AnyListDiffable : Int] else {
                    preconditionFailure("Cannot downcast dictionary to dictionary of Int")
            }
            for (idx, obj) in newArray.enumerated() {
                newDict.addIndex(useIndexPath: returnIndexPaths, section: toSection,
                                 index: idx, object: obj)
            }
            return ListIndexSetResult(inserts: IndexSet(0..<newCount), deletes: IndexSet(),
                                      updates: IndexSet(), moves: [],
                                      oldIndexDict: oldIndexDict,
                                      newIndexDict: newIndexDict)
        }
    }
    
    // symbol table uses the old/new array diffIdentifier as the key and IGListEntry as the value
    var table: [AnyListDiffable: ListEntry] = [:]
    
    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    var newResultsArray = Array(repeating: ListRecord(), count: newCount)
    for i in 0..<newCount {
        let key = newArray[i]
        var entry: ListEntry
        if let tableEntry = table[key] {
            entry = tableEntry
        } else {
            entry = ListEntry()
            table[key] = entry
        }
        entry.newCounter += 1
        
        // add NSNotFound for each occurence of the item in the new array
        entry.oldIndexes.append(nil)
        newResultsArray[i].entry = entry
    }
    
    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    var oldResultsArray = Array(repeating: ListRecord(), count: oldCount)
    for i in stride(from: oldCount - 1, through: 0, by: -1) {
        let key = oldArray[i]
        var entry: ListEntry
        if let tableEntry = table[key] {
            entry = tableEntry
        } else {
            entry = ListEntry()
            table[key] = entry
        }
        entry.oldCounter += 1
        
        // push the original indices where the item occurred onto the index stack
        entry.oldIndexes.append(i);
        oldResultsArray[i].entry = entry
    }
    
    // pass 3
    // handle data that occurs in both arrays
    for i in 0..<newCount {
        if let entry = newResultsArray[i].entry {
            assert(!entry.oldIndexes.isEmpty, "Old indexes is empty while iterating new item \(i). Should have nil")
            if let top = entry.oldIndexes.popLast(),
                let originalIndex = top {
                // originalIndex is not nil
                if originalIndex < oldCount {
                    let n = newArray[i]
                    let o = oldArray[originalIndex]
                }
            }
        }
    }
}


