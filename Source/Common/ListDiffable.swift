//
//  ListDiffable.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 The `ListDiffable` protocol provides methods needed to compare the identity and equality of two objects.
 */
protocol ListDiffable {
    
    /**
     Returns a key that uniquely identifies the object.
     
     - Returns: A key that can be used to uniquely identify the object.
     
     - Note: Two objects may share the same identifier, but are not equal. A common pattern is to use the `NSObject`
     category for automatic conformance. However this means that objects will be identified on their
     pointer value so finding updates becomes impossible.
     
     - Warning: This value should never be mutated.
     */
    var diffIndentifier: AnyHashable { get }
    
    /**
     Returns whether the receiver and a given object are equal.
     
     - Parameters:
        - object: The object to be compared to the receiver.
     
     - Returns: true if the receiver and object are equal, otherwise false.
     */
    func isEqualToDiffableObject(object: Any) -> Bool
}
