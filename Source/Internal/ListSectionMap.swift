//
//  ListSectionMap.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import DifferenceKit

/// The ListSectionMap provides a way to map a collection of objects to a collection of section
/// controllers and achieve constant-time lookups O(1).
struct ListSectionMap {
    /// The objects stored in the map.
    private(set) var objects: [AnyDifferentiable]

    /// `true` if the item count in map is zero, `false` otherwise.
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

    init() {
        objectIdToSectionControllerDict = [:]
        sectionControllerToSectionDict = [:]
        objects = []
    }

    /// Fetch a section controller given a section.
    ///
    /// - Parameter section: The section index of the section controller.
    /// - Returns: A section controller.
    func sectionController(forSection section: Int) -> ListSectionController? {
        if let object = object(forSection: section) {
            return objectIdToSectionControllerDict[object.differenceIdentifier]
        }
        return nil
    }

    /// Fetch a section controller given an object.
    ///
    /// - Parameter object: The object that maps to a section controller.
    /// - Returns: A section controller.
    func sectionController(for object: AnyDifferentiable) -> ListSectionController? {
        return objectIdToSectionControllerDict[object.differenceIdentifier]
    }

    /// Fetch the object for a section
    ///
    /// - Parameter section: The section index of the object.
    /// - Returns: The object corresponding to the section.
    func object(forSection section: Int) -> AnyDifferentiable? {
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
    func section(for object: AnyDifferentiable) -> Int? {
        if let sectionController = sectionController(for: object) {
            return section(for: sectionController)
        }
        return nil
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

    /// Update the map with objects and the section controller counterparts.
    ///
    /// - Parameters:
    ///   - objects: The objects in the collection.
    ///   - sectionControllers: The section controllers that map to each object.
    mutating func update(
        objects: [AnyDifferentiable],
        withSectionControllers sectionControllers: [ListSectionController]
    ) {
        assert(
            objects.count == sectionControllers.count,
            "Invalid parameter not satisfying objects.count == sectionControllers.count")

        reset()

        self.objects = objects

        guard
            let first = objects.first,
            let last = objects.last
        else {
            // objects array is empty
            return
        }

        for (section, object) in objects.enumerated() {
            let sectionController = sectionControllers[section]

            // set the index of the list for easy reverse lookup
            sectionControllerToSectionDict[sectionController] = section
            objectIdToSectionControllerDict[object.differenceIdentifier] = sectionController

            sectionController.isFirstSection = (object.differenceIdentifier == first.differenceIdentifier)
            sectionController.isLastSection = (object.differenceIdentifier == last.differenceIdentifier)
            sectionController.section = section
        }
    }

    /// Update an object with a new instance.
    ///
    /// - Parameter object: The object to update.
    mutating func update(_ object: AnyDifferentiable) {
        guard let section = section(for: object),
              let sectionController = sectionController(for: object)
        else { return }
        objects[section] = object
        sectionControllerToSectionDict[sectionController] = section
        objectIdToSectionControllerDict[object.differenceIdentifier] = sectionController
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

    // MARK: Private
    // both of these dictionaries allow fast lookups of objects, list objects, and indexes
    private var objectIdToSectionControllerDict: [AnyHashable: ListSectionController]
    private var sectionControllerToSectionDict: [ListSectionController: Int]

}

typealias ListSectionMapClosure = (AnyDifferentiable, ListSectionController, Int) -> Void
