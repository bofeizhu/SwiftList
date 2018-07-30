//
//  ListDebugger.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListDebugger {
    static func track(adapter: ListAdapter) {
        livingAdapters.insert(ListAdapterWeakBox(adapter))
    }

    static func clear() {
        livingAdapters.removeAll()
    }

    // MARK: Private
    private static var livingAdapters: Set<ListAdapterWeakBox> = []
}
