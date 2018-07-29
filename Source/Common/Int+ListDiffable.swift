//
//  Int+ListDiffable.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/10/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension Int: ListDiffable {
    public var diffIdentifier: AnyHashable {
        return self
    }
}
