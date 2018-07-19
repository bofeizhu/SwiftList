//
//  ListSectionController.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/13/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The base class for section controllers used in a list. This class is intended to be subclassed.
open class ListSectionController {
    
    /// Returns the number of items in the section.
    ///
    /// - Note: The count returned is used to drive the number of cells displayed for this section
    ///     controller. The default implementation returns 1.
    open var numberOfItems: Int {
        return 1
    }
    
    /// The view controller housing the adapter that created this section controller.
    ///
    /// - Note: Use this view controller to push, pop, present, or do other custom transitions.
    /// - Warning: It is considered very bad practice to cast this to a known view controller and
    ///     call methods on it other than for navigations and transitions.
    public weak var viewController: UIViewController?
    
    /// A context object for interacting with the collection. Use this property for accessing the
    /// collection size, dequeuing cells, reloading, inserting, deleting, etc.
    public weak var collectionContext: ListCollectionContext?
    
}

// MARK: Section Controller DispatchQueue Context
class ListSectionControllerDispatchQueueContext {
    weak var viewController: UIViewController?
    weak var collectionContext: ListCollectionContext?
}

let ListSectionControllerDispatchQueueKey =
    DispatchSpecificKey<[ListSectionControllerDispatchQueueContext]>()

func dispatchQueueContextStack() -> [ListSectionControllerDispatchQueueContext] {
    dispatchPrecondition(condition: .onQueue(.main))
    if let stack = DispatchQueue.main.getSpecific(key: ListSectionControllerDispatchQueueKey) {
        return stack
    }
    let stack: [ListSectionControllerDispatchQueueContext] = []
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
    return stack
}

func ListSectionControllerPushDispatchQueueContext(
    viewController: UIViewController,
    collectionContext: ListCollectionContext) {
    let context = ListSectionControllerDispatchQueueContext()
    context.viewController = viewController
    context.collectionContext = collectionContext
    var stack = dispatchQueueContextStack()
    stack.append(context)
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
}

func ListSectionControllerPopDispatchQueueContext() {
    var stack = dispatchQueueContextStack()
    guard stack.popLast() != nil else {
        assertionFailure("ListSectionController DispatchQueue stack is empty")
        return
    }
    DispatchQueue.main.setSpecific(key: ListSectionControllerDispatchQueueKey, value: stack)
}
