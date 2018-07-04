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
public enum ListDiffOption {
    /**
     Compare objects using `ObjectIdentifier`.
     */
    case ListDiffObjectIdentifier
    /**
     Compare objects using `hashValue`.
     */
    case ListDiffEquality
}

/**
 Creates a diff using indexes between two collections.
 - Parameters:
    - oldArray: The old objects to diff against.
    - newArray: The new objects.
    - option: An option on how to compare objects.
 - Returns: A result object containing affected indexes.
 */
public func ListDiff(oldArray: [AnyListDiffable], newArray: [AnyListDiffable],
                     option: ListDiffOption) -> ListIndexSetResult {
    let result = ListDiffing(returnIndexPaths: false, fromSection: 0, toSection: 0,
                             oldArray: oldArray, newArray: newArray,
                             option: option, experiments: ListExperiment(rawValue: 0))
    guard let indexSetResult = result as? ListIndexSetResult else {
        preconditionFailure("Cannot cast diff result to `ListIndexSetResult`")
    }
    return indexSetResult
}

/**
 Creates a diff using index paths between two collections.
 - Parameters:
    - section: The old section.
    - newSection: The new section.
    - oldArray: The old objects to diff against.
    - newArray: The new objects.
    - option: An option on how to compare objects.
 - Returns: A result object containing affected indexes.
 */
public func ListDiffPaths(fromSection section: Int, toSection newSection: Int,
                          oldArray: [AnyListDiffable], newArray: [AnyListDiffable],
                          option: ListDiffOption) -> ListIndexPathResult {
    let result = ListDiffing(returnIndexPaths: true,
                             fromSection: section, toSection: newSection,
                             oldArray: oldArray, newArray: newArray,
                             option: option, experiments: ListExperiment(rawValue: 0))
    guard let indexPathResult = result as? ListIndexPathResult else {
        preconditionFailure("Cannot cast diff result to `ListIndexPathResult`")
    }
    return indexPathResult
}

/// Used to track data stats while diffing.
fileprivate final class ListEntry {
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
fileprivate struct ListRecord {
    var entry: ListEntry?
    var index: Int?
}

fileprivate extension Dictionary where Key == Int, Value == IndexPath {
    mutating func addIndexPath(section: Int, index: Int, toObject object: AnyListDiffable) {
        let indexPath = IndexPath(item: index, section: section)
        self[object.hashValue] = indexPath
    }
    
    mutating func addIndexPathsAndPopulateMap(_ array: [AnyListDiffable], section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (idx, obj) in array.enumerated() {
            let indexPath = IndexPath(item: idx, section: section)
            indexPaths.append(indexPath)
            self[obj.hashValue] = indexPath
        }
        return indexPaths
    }
}

fileprivate extension Dictionary where Key == Int, Value == Int {
    mutating func add(index: Int, toObject object: AnyListDiffable) {
        self[object.hashValue] = index
    }
}

fileprivate func ListTableKey(object: AnyListDiffable) -> Int {
    return object.hashValue
}

fileprivate func ListDiffing(returnIndexPaths: Bool,
                             fromSection section: Int, toSection newSection: Int,
                             oldArray: [AnyListDiffable], newArray: [AnyListDiffable],
                             option: ListDiffOption, experiments: ListExperiment) -> Any {
    let newCount = newArray.count
    let oldCount = oldArray.count
    
    var oldIndexPathDict: [Int: IndexPath] = [:]
    var newIndexPathDict: [Int: IndexPath] = [:]
    var oldIndexDict: [Int: Int] = [:]
    var newIndexDict: [Int: Int] = [:]
    
    // if no new objects, everything from the oldArray is deleted
    // take a shortcut and just build a delete-everything result
    if newCount == 0 {
        if returnIndexPaths {
            let deletes = oldIndexPathDict.addIndexPathsAndPopulateMap(oldArray, section: section)
            return ListIndexPathResult(inserts: [],
                                       deletes: deletes,
                                       updates: [], moves: [],
                                       oldIndexPathDict: oldIndexPathDict,
                                       newIndexPathDict: newIndexPathDict)
        } else {
            for (idx, obj) in oldArray.enumerated() {
                oldIndexDict.add(index: idx, toObject: obj)
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
            let inserts = newIndexPathDict.addIndexPathsAndPopulateMap(newArray, section: newSection)
            return ListIndexPathResult(inserts: inserts, deletes: [],
                                       updates: [], moves: [],
                                       oldIndexPathDict: oldIndexPathDict,
                                       newIndexPathDict: newIndexPathDict)
        } else {
            for (idx, obj) in newArray.enumerated() {
                newIndexDict.add(index: idx, toObject: obj)
            }
            return ListIndexSetResult(inserts: IndexSet(0..<newCount), deletes: IndexSet(),
                                      updates: IndexSet(), moves: [],
                                      oldIndexDict: oldIndexDict,
                                      newIndexDict: newIndexDict)
        }
    }
    
    // symbol table uses the old/new array diffIdentifier as the key and IGListEntry as the value
    var table: [Int: ListEntry] = [:]
    
    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    var newResultsArray = [ListRecord](repeating: ListRecord(), count: newCount)
    for i in 0..<newCount {
        let object = newArray[i]
        var entry: ListEntry
        if let tableEntry = table[ListTableKey(object: object)] {
            entry = tableEntry
        } else {
            entry = ListEntry()
            table[ListTableKey(object: object)] = entry
        }
        entry.newCounter += 1
        
        // add nil for each occurence of the item in the new array
        entry.oldIndexes.append(nil)
        newResultsArray[i].entry = entry
    }
    
    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    var oldResultsArray = [ListRecord](repeating: ListRecord(), count: oldCount)
    for i in stride(from: oldCount - 1, through: 0, by: -1) {
        let object = oldArray[i]
        var entry: ListEntry
        if let tableEntry = table[ListTableKey(object: object)] {
            entry = tableEntry
        } else {
            entry = ListEntry()
            table[ListTableKey(object: object)] = entry
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
                    switch option {
                    case .ListDiffObjectIdentifier:
                        assert(type(of: n.base) is AnyClass && type(of: o.base) is AnyClass,
                               "Objects should have class-type when using `ListDiffObjectIdentifier`")
                        let nobj = n.base as AnyObject
                        let oobj = o.base as AnyObject
                        if nobj !== oobj {
                            entry.updated = true
                        }
                        
                    case .ListDiffEquality:
                        if n != o {
                            entry.updated = true
                        }
                    }
                }
                
                if entry.newCounter > 0, entry.oldCounter > 0 {
                    newResultsArray[i].index = originalIndex
                    oldResultsArray[originalIndex].index = i
                }
            }
        }
    }
    
    // storage for final IndexPaths
    var indexPathInserts = [IndexPath](), indexPathUpdates = [IndexPath](), indexPathDeletes = [IndexPath]()
    var indexPathMoves = [ListMoveIndexPath]()
    
    // storage for final indexes
    var indexInserts = IndexSet(), indexUpdates = IndexSet(), indexDeletes = IndexSet()
    var indexMoves = [ListMoveIndex]()
    
    // track offsets from deleted items to calculate where items have moved
    var deleteOffsets = Array(repeating: 0, count: oldCount)
    var insertOffsets = Array(repeating: 0, count: newCount)
    var runningOffset = 0
    
    // iterate old array records checking for deletes
    // incremement offset for each delete
    for i in 0..<oldCount {
        deleteOffsets[i] = runningOffset
        let record = oldResultsArray[i]
        // if the record index in the new array doesn't exist, its a delete
        if record.index == nil {
            if returnIndexPaths {
                let indexPath = IndexPath(item: i, section: section)
                indexPathDeletes.append(indexPath)
            } else {
                indexDeletes.insert(i)
            }
            runningOffset += 1
        }
        
        if returnIndexPaths {
            oldIndexPathDict.addIndexPath(section: section, index: i, toObject: oldArray[i])
        } else {
            oldIndexDict.add(index: i, toObject: oldArray[i])
        }
    }
    
    // reset and track offsets from inserted items to calculate where items have moved
    runningOffset = 0
    
    for i in 0..<newCount {
        insertOffsets[i] = runningOffset
        let record = newResultsArray[i]
        if let oldIndex = record.index {
            // note that an entry can be updated /and/ moved
            if let entry = record.entry, entry.updated {
                if returnIndexPaths {
                    let indexPath = IndexPath(item: oldIndex, section: section)
                    indexPathUpdates.append(indexPath)
                } else {
                    indexUpdates.insert(oldIndex)
                }
            }
            
            // calculate the offset and determine if there was a move
            // if the indexes match, ignore the index
            let insertOffset = insertOffsets[i]
            let deleteOffset = deleteOffsets[oldIndex]
            if oldIndex - deleteOffset + insertOffset != i {
                if returnIndexPaths {
                    let from = IndexPath(item: oldIndex, section: section)
                    let to = IndexPath(item: i, section: newSection)
                    let move = ListMoveIndexPath(from: from, to: to)
                    indexPathMoves.append(move)
                } else {
                    let move = ListMoveIndex(from: oldIndex, to: i)
                    indexMoves.append(move)
                }
            }
        } else {
            // add to inserts if the opposing index is nil
            if returnIndexPaths {
                let indexPath = IndexPath(item: i, section: newSection)
                indexPathInserts.append(indexPath)
            } else {
                indexInserts.insert(i)
            }
            runningOffset += 1
        }
        
        if returnIndexPaths {
            newIndexPathDict.addIndexPath(section: newSection, index: i, toObject: newArray[i])
        } else {
            newIndexDict.add(index: i, toObject: newArray[i])
        }
    }
    
    if returnIndexPaths {
        assert(oldCount + indexPathInserts.count - indexPathDeletes.count == newCount,
               "Sanity check failed applying \(indexPathInserts.count) inserts and \(indexPathDeletes.count) deletes to old count \(oldCount) equaling new count \(newCount)")
        return ListIndexPathResult(inserts: indexPathInserts, deletes: indexPathDeletes,
                                   updates: indexPathUpdates, moves: indexPathMoves,
                                   oldIndexPathDict: oldIndexPathDict, newIndexPathDict: newIndexPathDict)
    } else {
        assert(oldCount + indexInserts.count - indexDeletes.count == newCount,
               "Sanity check failed applying \(indexInserts.count) inserts and \(indexDeletes.count) deletes to old count \(oldCount) equaling new count \(newCount)")
        return ListIndexSetResult(inserts: indexInserts, deletes: indexDeletes,
                                  updates: indexUpdates, moves: indexMoves,
                                  oldIndexDict: oldIndexDict, newIndexDict: newIndexDict)
    }
}

//TODO: Add Experiments

