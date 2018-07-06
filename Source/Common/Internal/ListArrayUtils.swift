//
//  ListArrayUtils.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/5/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension Array where Element == AnyListDiffable {
    func hasDuplicateHashValue() {
        var table: [Int: Element] = [:]
        for object in self {
            let hashValue = object.hashValue
            if let previousObject = table[hashValue] {
                preconditionFailure("Duplicate identifier \(hashValue) for object \(object) with object \(previousObject)")
            } else {
                table[hashValue] = object
            }
        }
    }
}
