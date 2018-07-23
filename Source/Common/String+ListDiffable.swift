//
//  String+ListDiffable.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/10/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension String: ListDiffable {
    public var diffIdentifier: AnyHashable {
        return self
    }
}

extension Substring: ListDiffable {
    public var diffIdentifier: AnyHashable {
        return self
    }
}
