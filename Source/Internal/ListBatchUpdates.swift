//
//  ListBatchUpdates.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListBatchUpdates {
    private(set) var sectionReloads: IndexSet = IndexSet()
    
    var hasChanges: Bool {
        return sectionReloads.count > 0
    }
}
