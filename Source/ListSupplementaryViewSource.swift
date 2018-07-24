//
//  ListSupplementaryViewSource.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/19/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// Conform to this protocol to provide information about a list's supplementary views. This data is
/// used in `ListAdapter` which then configures and maintains a `UICollectionView`. The
/// supplementary API reflects that in `UICollectionView`, `UICollectionViewLayout`, and
/// `UICollectionViewDataSource`.
public protocol ListSupplementaryViewSource: AnyObject {
    
    /// An array of element kind strings that the supplementary source handles.
    var supportedElementKinds: [String] { get }
    
    /// Asks the SupplementaryViewSource for a configured supplementary view for the specified kind
    /// and index.
    ///
    /// - Parameters:
    ///   - kind: The kind of supplementary view being requested.
    ///   - index: The index for the supplementary veiw being requested.
    /// - Returns: A configured supplementary view for the specified kind and index.
    /// - Note: This is your opportunity to do any supplementary view setup and configuration.
    /// - Warning: You should never init new views in this method. Instead deque a view from the
    ///     `ListCollectionContext`.
    func viewForSupplementaryElement(ofKind kind: String, at index: Int) -> UICollectionReusableView
    
    /// Asks the SupplementaryViewSource for the size of a supplementary view for the given kind and
    /// index path.
    ///
    /// - Parameters:
    ///   - kind: The kind of supplementary view.
    ///   - index: The index of the requested view.
    /// - Returns: The size for the supplementary view.
    func sizeForSupplementaryView(ofKind kind: String, at index: Int) -> CGSize?
}
