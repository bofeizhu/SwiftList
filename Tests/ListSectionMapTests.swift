//
//  ListSectionMapTests.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListSectionMapTests: XCTestCase {
    func testWhenUpdatingItemsThatArraysAreEqual() {
        let objects = [1, 2, 3].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertEqual(objects, map.objects)
    }
}
