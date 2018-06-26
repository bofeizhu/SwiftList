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
protocol ListDiffable: Equatable {
    
    /**
     Returns a key that uniquely identifies the object.
     
     - Returns: A key that can be used to uniquely identify the object.
     
     - Warning: This value should never be mutated.
     */
    var diffIndentifier: AnyHashable { get }
}
