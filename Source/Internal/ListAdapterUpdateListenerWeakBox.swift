//
//  ListAdapterUpdateListenerWeakBox.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// A weak box for `ListAdapterUpdateListener`
final class ListAdapterUpdateListenerWeakBox {
    weak var updateListener: ListAdapterUpdateListener?
    init(_ updateListener: ListAdapterUpdateListener) {
        self.updateListener = updateListener
    }
}

extension ListAdapterUpdateListenerWeakBox: Hashable {
    var hashValue: Int {
        if let updateListener = updateListener {
            return ObjectIdentifier(updateListener).hashValue
        }
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        if let updateListener = updateListener {
            hasher.combine(ObjectIdentifier(updateListener))
        }
        
    }

    static func == (
        lhs: ListAdapterUpdateListenerWeakBox,
        rhs: ListAdapterUpdateListenerWeakBox
    ) -> Bool {
        if let lhs = lhs.updateListener,
            let rhs = rhs.updateListener {
            return lhs === rhs
        }
        return false
    }
}
