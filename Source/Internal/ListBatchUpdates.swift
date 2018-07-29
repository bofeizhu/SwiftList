//
//  ListBatchUpdates.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListBatchUpdates {
    private(set) var sectionReloads: IndexSet = []
    
    private(set) var itemInserts: [IndexPath] = []
    private(set) var itemDeletes: [IndexPath] = []
    
    private(set) var itemReloads: [ListReloadIndexPath] = []
    private(set) var itemMoves: [ListMoveIndexPath] = []
    private(set) var itemUpdateClosures: [ListItemUpdateClosure] = []
    private(set) var itemCompletionClosures: [ListUpdatingCompletion] = []
    
    var hasChanges: Bool {
        return itemUpdateClosures.count > 0 || sectionReloads.count > 0
        || itemInserts.count > 0 || itemMoves.count > 0
        || itemReloads.count > 0 || itemDeletes.count > 0
    }
    
    func delete(items: [IndexPath]) {
        itemDeletes.append(contentsOf: items)
    }
    
    func insert(items: [IndexPath]) {
        itemInserts.append(contentsOf: items)
    }
    
    func reload(sections: IndexSet) {
        sectionReloads.formUnion(sections)
    }
    
    func append(reload: ListReloadIndexPath) {
        itemReloads.append(reload)
    }
    
    func append(move: ListMoveIndexPath) {
        itemMoves.append(move)
    }
    
    func append(completionClosure: @escaping ListUpdatingCompletion) {
        itemCompletionClosures.append(completionClosure)
    }
    
    func append(updateClosure: @escaping ListItemUpdateClosure) {
        itemUpdateClosures.append(updateClosure)
    }
}
