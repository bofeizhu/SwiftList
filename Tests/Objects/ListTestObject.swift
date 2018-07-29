//
//  ListTestObject.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 6/30/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

struct ListTestObject: ListDiffable {
    let key: AnyHashable
    var value: AnyHashable
    
    init(key: AnyHashable, value: AnyHashable) {
        self.key = key
        self.value = value
    }
    
    var diffIdentifier: AnyHashable {
        return key
    }
    
    static func == (lhs: ListTestObject, rhs: ListTestObject) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

final class ListTestClassObject: ListDiffable {
    let key: AnyHashable
    var value: AnyHashable
    
    init(key: AnyHashable, value: AnyHashable) {
        self.key = key
        self.value = value
    }
    
    var diffIdentifier: AnyHashable {
        return key
    }
    
    static func == (lhs: ListTestClassObject, rhs: ListTestClassObject) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}
