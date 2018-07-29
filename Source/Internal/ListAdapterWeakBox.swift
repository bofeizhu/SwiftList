//
//  ListAdapterWeakBox.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/22/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//


/// A weak box for `ListAdapter`
final class ListAdapterWeakBox {
    weak var listAdapter: ListAdapter?
    init(_ listAdapter: ListAdapter) {
        self.listAdapter = listAdapter
    }
}

extension ListAdapterWeakBox: Hashable {
    var hashValue: Int {
        if let listAdapter = listAdapter {
            return ObjectIdentifier(listAdapter).hashValue
        }
        return 0
    }
    
    static func == (lhs: ListAdapterWeakBox, rhs: ListAdapterWeakBox) -> Bool {
        if let lhs = lhs.listAdapter,
           let rhs = rhs.listAdapter {
            return lhs === rhs
        }
        return false
    }
}
