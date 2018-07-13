//
//  ListDiffable.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/27/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

//public typealias ListDiffable = Hashable
//public typealias AnyListDiffable = AnyHashable

/**
 The `ListDiffable` protocol provides methods needed to compare
 the identity and equality of two objects.
 */
public protocol ListDiffable: Equatable {
    /**
     A key that uniquely identifies the object.
     
     - Note: Two objects may share the same identifier, but are not equal.
     - Warning: This value should never be mutated.
     */
    var diffIdentifier: AnyHashable { get }
}

// TODO: wait for general Generalized existentials
// https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#generalized-existentials

/**
 A type-erased diffable value.
 
 The `AnyListDiffable` type forwards identity and equality comparisons
 to an underlying diffable value, hiding its specific underlying type.
 */
public struct AnyListDiffable {
    var _box: _AnyListDiffableBox
    
    /**
     Creates a type-erased diffable value that wraps the given instance.
     - Parameter base: A diffable value to wrap.
     */
    public init<T: ListDiffable>(_ base: T) {
        _box = _ConcreteListDiffableBox(base)
    }
    
    public var base: Any {
        return _box._base
    }
}

extension Array where Element: ListDiffable {
    public func typeErased() -> [AnyListDiffable] {
        return self.map { AnyListDiffable($0) }
    }
}

extension AnyListDiffable: Equatable {
    public static func == (lhs: AnyListDiffable, rhs: AnyListDiffable) -> Bool {
        return lhs._box._canonicalBox._isEqual(to: rhs._box._canonicalBox) ?? false
    }
}

extension AnyListDiffable: ListDiffable {
    public var diffIdentifier: AnyHashable {
        return _box._canonicalBox._diffIdentifier
    }
}

protocol _AnyListDiffableBox {
    var _canonicalBox: _AnyListDiffableBox { get }
    
    /**
     Determine whether values in the boxes are equivalent.
     - Precondition: `self` and `box` are in canonical form.
     - Returns: `nil` to indicate that the boxes store different types, so
     no comparison is possible. Otherwise, contains the result of `==`.
     */
    func _isEqual(to box: _AnyListDiffableBox) -> Bool?
    
    var _diffIdentifier: AnyHashable { get }
    
    var _base: Any { get }
    func _unbox<T: ListDiffable>() -> T?
}

extension _AnyListDiffableBox {
    var _canonicalBox: _AnyListDiffableBox {
        return self
    }
}

struct _ConcreteListDiffableBox<Base: ListDiffable> : _AnyListDiffableBox {
    var _baseListDiffable: Base
    
    init (_ base: Base) {
        _baseListDiffable = base
    }
    
    func _unbox<T: ListDiffable>() -> T? {
        return (self as _AnyListDiffableBox as? _ConcreteListDiffableBox<T>)?._baseListDiffable
    }
    
    var _diffIdentifier: AnyHashable {
        return _baseListDiffable.diffIdentifier
    }
    
    func _isEqual(to rhs: _AnyListDiffableBox) -> Bool? {
        if let rhs: Base = rhs._unbox() {
            return _baseListDiffable == rhs
        }
        return nil
    }
    
    var _base: Any {
        return _baseListDiffable
    }
}
