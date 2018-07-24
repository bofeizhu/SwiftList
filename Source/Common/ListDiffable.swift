//
//  ListDiffable.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/27/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// The `ListDiffable` protocol provides methods needed to compare the identity and equality of
/// two objects.
public protocol ListDiffable: Equatable {
    
    /// A key that uniquely identifies the object.
    /// - Note: Two objects may share the same identifier, but are not equal.
    /// - Warning: This value should never be mutated.
    var diffIdentifier: AnyHashable { get }
}

// TODO: wait for general Generalized existentials
// https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#generalized-existentials

/// A type-erased diffable value.
///
/// The `AnyListDiffable` type forwards identity and equality comparisons to an underlying diffable
/// value, hiding its specific underlying type.
public struct AnyListDiffable {
    private var box: AnyListDiffableBox
    
    /// Creates a type-erased diffable value that wraps the given instance.
    ///
    /// - Parameter base: A diffable value to wrap.
    public init<T: ListDiffable>(_ base: T) {
        box = ConcreteListDiffableBox(base)
    }
    
    public var base: Any {
        return box.base
    }
}

extension Array where Element: ListDiffable {
    public func typeErased() -> [AnyListDiffable] {
        return self.map { AnyListDiffable($0) }
    }
}

extension AnyListDiffable: Equatable {
    public static func == (lhs: AnyListDiffable, rhs: AnyListDiffable) -> Bool {
        return lhs.box.canonicalBox.isEqual(to: rhs.box.canonicalBox) ?? false
    }
}

extension AnyListDiffable: ListDiffable {
    public var diffIdentifier: AnyHashable {
        return box.canonicalBox.diffIdentifier
    }
}

private protocol AnyListDiffableBox {
    var canonicalBox: AnyListDiffableBox { get }
    
    /// Determine whether values in the boxes are equivalent.
    ///
    /// - Precondition: `self` and `box` are in canonical form.
    /// - Parameter box: The box for the value.
    /// - Returns: `nil` to indicate that the boxes store different types, so
    ///     no comparison is possible. Otherwise, contains the result of `==`.
    func isEqual(to box: AnyListDiffableBox) -> Bool?
    
    var diffIdentifier: AnyHashable { get }
    
    var base: Any { get }
    func unbox<T: ListDiffable>() -> T?
}

extension AnyListDiffableBox {
    var canonicalBox: AnyListDiffableBox {
        return self
    }
}

private struct ConcreteListDiffableBox<Base: ListDiffable> : AnyListDiffableBox {
    var baseListDiffable: Base
    
    init (_ base: Base) {
        baseListDiffable = base
    }
    
    func unbox<T: ListDiffable>() -> T? {
        return (self as AnyListDiffableBox as? ConcreteListDiffableBox<T>)?.baseListDiffable
    }
    
    var diffIdentifier: AnyHashable {
        return baseListDiffable.diffIdentifier
    }
    
    func isEqual(to rhs: AnyListDiffableBox) -> Bool? {
        if let rhs: Base = rhs.unbox() {
            return baseListDiffable == rhs
        }
        return nil
    }
    
    var base: Any {
        return baseListDiffable
    }
}
