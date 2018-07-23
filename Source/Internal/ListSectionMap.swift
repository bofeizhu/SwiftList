//
//  ListSectionMap.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

typealias ListSectionMapClosure = (AnyListDiffable, ListSectionController, Int) -> Void

struct ListSectionMap {
    
    /// The objects stored in the map.
    private(set) var objects: [AnyListDiffable]
    
    init() {
        objectIdToSectionControllerDict = [:]
        sectionControllerToSectionDict = [:]
        objects = []
    }
    
    /// Update the map with objects and the section controller counterparts.
    ///
    /// - Parameters:
    ///   - objects: The objects in the collection.
    ///   - sectionControllers: The section controllers that map to each object.
    mutating func update(
        objects: [AnyListDiffable],
        withSectionControllers sectionControllers: [ListSectionController]) {
        assert(
            objects.count == sectionControllers.count,
            "Invalid parameter not satisfying objects.count == sectionControllers.count")
        
        reset()
        
        self.objects = objects
        
        let first = objects.first
        let last = objects.last
        
        for (section, object) in objects.enumerated() {
            let sectionController = sectionControllers[section]
            
            // set the index of the list for easy reverse lookup
            sectionControllerToSectionDict[sectionController] = section
            objectIdToSectionControllerDict[object.diffIdentifier] = sectionController
            
            sectionController.isFirstSection = (object == first)
            sectionController.isLastSection = (object == last)
            sectionController.section = section
        }
    }
    
    /// Fetch a section controller given a section.
    ///
    /// - Parameter section: The section index of the section controller.
    /// - Returns: A section controller.
    func sectionController(for section: Int) -> ListSectionController? {
        if let object = object(for: section) {
            return objectIdToSectionControllerDict[object.diffIdentifier]
        }
        return nil
    }
    
    /// Fetch a section controller given an object.
    ///
    /// - Parameter object: The object that maps to a section controller.
    /// - Returns: A section controller.
    func sectionController(for object: AnyListDiffable) -> ListSectionController? {
        return objectIdToSectionControllerDict[object.diffIdentifier]
    }
    
    /// Fetch the object for a section
    ///
    /// - Parameter section: The section index of the object.
    /// - Returns: The object corresponding to the section.
    func object(for section: Int) -> AnyListDiffable? {
        guard section < objects.count else {
            return nil
        }
        return objects[section]
    }
    
    /// Look up the section index for a section controller.
    ///
    /// - Parameter sectionController: The sectionController to look up.
    /// - Returns: The section index of the given section controller if it exists, `nil` otherwise.
    func section(for sectionController: ListSectionController) -> Int? {
        return sectionControllerToSectionDict[sectionController]
    }
    
    /// Look up the section index for an object.
    ///
    /// - Parameter object: The object to look up.
    /// - Returns: The section index of the given object if it exists, `nil` otherwise.
    func section(for object: AnyListDiffable) -> Int? {
        if let sectionController = sectionController(for: object) {
            return section(for: sectionController)
        }
        return nil
    }
    
    /// Remove all saved objects and section controllers.
    mutating func reset() {
        map { (_, sectionController, _) in
            sectionController.section = nil
            sectionController.isFirstSection = false
            sectionController.isLastSection = false
        }
        sectionControllerToSectionDict = [:]
        objectIdToSectionControllerDict = [:]
    }
    
    ///  Applies a given closure to the entries of the section controller map.
    ///
    /// - Parameter transform: A closure to operate on entries in the section controller map.
    func map(_ transform: ListSectionMapClosure) {
        for (section, object) in objects.enumerated() {
            if let sectionController = sectionController(for: object) {
                transform(object, sectionController, section)
            }
        }
    }
    
    var isItemCountZero: Bool {
        for object in objects {
            if let sectionController = sectionController(for: object) {
                if sectionController.numberOfItems > 0 {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: Private
    // both of these dictionaries allow fast lookups of objects, list objects, and indexes
    private var objectIdToSectionControllerDict: [AnyHashable: ListSectionController]
    private var sectionControllerToSectionDict: [ListSectionController: Int]
    
}
