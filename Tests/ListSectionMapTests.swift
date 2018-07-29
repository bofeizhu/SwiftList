//
//  ListSectionMapTests.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/24/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListSectionMapTests: XCTestCase {
    func testWhenUpdatingItemsThatArraysAreEqual() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertEqual(objects, map.objects)
    }
    
    func testWhenUpdatingItemsThatSectionControllersAreMappedForSection() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertEqual(map.sectionController(forSection: 1)!, sectionControllers[1])
    }
    
    func testWhenUpdatingItemsThatSectionControllersAreMappedForItem() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertEqual(map.sectionController(for: AnyListDiffable(1))!, sectionControllers[1])
    }
    
    func testQhenUpdatingItemsThatSectionsAreMappedForSectionController() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertEqual(map.section(for: sectionControllers[1])!, 1)
    }
    
    func testWhenUpdatingItemsWithUnknownItemThatSectionControllerIsNil() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertNil(map.sectionController(for: AnyListDiffable(4)))
    }
    
    func testWhenUpdatingItemsWithSectionControllerThatSectionIsNil() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertNil(map.section(for: ListSectionController()))
    }
    
    func testWhenAccessingOOBSectionThatNilIsReturned() {
        let objects = [0, 1, 2].typeErased()
        let sectionControllers = [
            ListSectionController(),
            ListSectionController(),
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        XCTAssertNil(map.object(forSection: 4))
    }
    
    func testWhenUpdatingItemsThatSectionControllerIndexesAreUpdated() {
        let objects = [0, 1, 2].typeErased()
        let one = ListSectionController()
        XCTAssertNil(one.section)
        
        let sectionControllers = [
            ListSectionController(),
            one,
            ListSectionController(),
        ]
        var map = ListSectionMap()
        map.update(objects: objects, withSectionControllers: sectionControllers)
        
        XCTAssertEqual(one.section!, 1)
        XCTAssertFalse(one.isFirstSection)
    }
}
