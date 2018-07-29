//
//  ListDisplayHandler.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListDisplayHandler {
    /// Act as a counted set of the currently visible section controllers.
    private(set) var visibleSections: [ListSectionController: Int] = [:]
    
    /// Tells the handler that a cell will be displayed in the `ListAdapter`.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter the cell will display in.
    ///   - sectionController: The section controller that manages the cell.
    ///   - cell: A cell that will be displayed.
    ///   - object: The object that powers the section controller.
    ///   - indexPath: The index path of the cell in the `UICollectionView`.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        willDisplayCell cell: UICollectionViewCell,
        for object: AnyListDiffable,
        at indexPath: IndexPath) {
        sectionController.displayDelegate?.listAdapter(
            listAdapter,
            sectionController: sectionController,
            willDisplayCell: cell,
            at: indexPath.item)
        self.listAdapter(
            listAdapter,
            sectionController: sectionController,
            willDisplayReusableView: cell,
            for: object,
            at: indexPath)
    }
    
    /// Tells the handler that a cell did end display in the `ListAdapter`.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter the cell displayed in.
    ///   - sectionController: The section controller that manages the cell.
    ///   - cell: A cell that was no longer displayed.
    ///   - indexPath: The index path of the cell in the UICollectionView.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        didEndDisplayingCell cell: UICollectionViewCell,
        at indexPath: IndexPath) {
        guard let object = removeObject(for: cell) else {
            return
        }
        sectionController.displayDelegate?.listAdapter(
            listAdapter,
            sectionController: sectionController,
            didEndDisplayingCell: cell,
            at: indexPath.item)
        self.listAdapter(
            listAdapter,
            sectionController: sectionController,
            didEndDisplayingReusableView: cell,
            for: object,
            at: indexPath)
    }
    
    /// Tells the handler that a supplementary view will be displayed in the `ListAdapter`.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter the supplementary view will display in.
    ///   - sectionController: The section controller that manages the supplementary view.
    ///   - view: A supplementary view that will be displayed.
    ///   - object: The object that powers the section controller.
    ///   - indexPath: The index path of the supplementary view in the UICollectionView.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        willDisplaySupplementaryView view: UICollectionReusableView,
        for object: AnyListDiffable,
        at indexPath: IndexPath) {
        self.listAdapter(
            listAdapter,
            sectionController: sectionController,
            willDisplayReusableView: view,
            for: object,
            at: indexPath)
    }
    
    ///  Tells the handler that a supplementary view did end display in the ListAdapter.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter the supplementary view will display in.
    ///   - sectionController: The section controller that manages the supplementary view.
    ///   - view: A supplementary view that will be displayed.
    ///   - indexPath: The index path of the supplementary view in the UICollectionView.
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        at indexPath: IndexPath) {
        guard let object = removeObject(for: view) else {
            return
        }
        self.listAdapter(
            listAdapter,
            sectionController: sectionController,
            didEndDisplayingReusableView: view,
            for: object,
            at: indexPath)
    }
    
    // Private
    private var visibleViewObjectDict: [UICollectionReusableView: AnyListDiffable] = [:]
}

private extension ListDisplayHandler {
    func removeObject(for view: UICollectionReusableView) -> AnyListDiffable? {
        return visibleViewObjectDict.removeValue(forKey: view)
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        willDisplayReusableView view: UICollectionReusableView,
        for object: AnyListDiffable,
        at indexPath: IndexPath) {
        visibleViewObjectDict[view] = object
        if visibleSections.count(sectionController) == 0 {
            sectionController.displayDelegate?.listAdapter(
                listAdapter,
                willDisplay: sectionController)
            listAdapter.delegate?.listAdapter(
                listAdapter,
                willDisplay: object,
                at: indexPath.section)
        }
        visibleSections.add(sectionController)
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionController: ListSectionController,
        didEndDisplayingReusableView view: UICollectionReusableView,
        for object: AnyListDiffable,
        at indexPath: IndexPath) {
        let section = indexPath.section
        
        visibleSections.remove(sectionController)
        
        if visibleSections.count(sectionController) == 0 {
            sectionController.displayDelegate?.listAdapter(
                listAdapter,
                didEndDisplaying: sectionController)
            listAdapter.delegate?.listAdapter(
                listAdapter,
                didEndDisplaying: object,
                at: section)
        }
    }
}

fileprivate extension Dictionary where Key == ListSectionController, Value == Int {
    mutating func add(_ sectionController: ListSectionController) {
        if let count = self[sectionController] {
            self[sectionController] = count + 1
        } else {
            self[sectionController] = 1
        }
    }
    
    mutating func remove(_ sectionController: ListSectionController) {
        guard let count = self[sectionController] else {
            return
        }
        if count > 1 {
            self[sectionController] = count - 1
        } else {
            removeValue(forKey: sectionController)
        }
    }
    
    func count(_ sectionController: ListSectionController) -> Int {
        return self[sectionController] ?? 0
    }
}
