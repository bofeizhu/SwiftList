//
//  ListBatchUpdates.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListBatchUpdates {
    private(set) var sectionReloads: IndexSet = IndexSet()
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
    
    func delete(_ array: [IndexPath]) {
        itemDeletes.append(contentsOf: array)
    }
    
    func insert(_ array: [IndexPath]) {
        itemInserts.append(contentsOf: array)
    }
}
