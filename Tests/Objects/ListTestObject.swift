//
//  ListTestObject.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 6/30/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

struct ListTestObject: ListDiffable {
    let key: AnyHashable
    var value: AnyHashable
    
    init(key: AnyHashable, value: AnyHashable) {
        self.key = key
        self.value = value
    }
    
    var hashValue: Int {
        return key.hashValue
    }
    
    static func == (lhs: ListTestObject, rhs: ListTestObject) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

class ListTestClassObject: ListDiffable {
    let key: AnyHashable
    var value: AnyHashable
    
    init(key: AnyHashable, value: AnyHashable) {
        self.key = key
        self.value = value
    }
    
    var hashValue: Int {
        return key.hashValue
    }
    
    static func == (lhs: ListTestClassObject, rhs: ListTestClassObject) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}
