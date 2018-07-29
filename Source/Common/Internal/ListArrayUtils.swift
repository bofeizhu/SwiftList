//
//  ListArrayUtils.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/5/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension Array where Element == AnyListDiffable {
    /// - Warning: O(n) time complexity
    func checkDuplicateDiffIdentifier() {
        var table: [AnyHashable: Element] = [:]
        for object in self {
            let diffIdentifier = object.diffIdentifier
            if let previousObject = table[diffIdentifier] {
                preconditionFailure(
                    "Duplicate identifier \(diffIdentifier)" +
                        "for object \(object) with object \(previousObject)"
                )
            } else {
                table[diffIdentifier] = object
            }
        }
    }
}
