//
//  ListCollectionViewInteractiveReorderingLayout.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/// A `UICollectionViewLayout` subclass with interactive reordering implemented.
/// - Warning: All the layouts using interactive reordering should be subclassed from
///     `ListCollectionViewInteractiveReorderingLayout`
open class ListCollectionViewInteractiveReorderingLayout:
    UICollectionViewLayout,
    ListInteractiveReordering
{
    public weak var listAdapter: ListAdapter?
    
    open override func targetIndexPath(
        forInteractivelyMovingItem previousIndexPath: IndexPath,
        withPosition position: CGPoint) -> IndexPath {
        let originalTargetIndexPath = super.targetIndexPath(
            forInteractivelyMovingItem: previousIndexPath,
            withPosition: position)
        return targetIndexPath(
            forInteractivelyMovingItem: previousIndexPath,
            withPosition: position,
            originalTargetIndexPath: originalTargetIndexPath)
    }
    
    open override func invalidationContext(
        forInteractivelyMovingItems targetIndexPaths: [IndexPath],
        withTargetPosition targetPosition: CGPoint,
        previousIndexPaths: [IndexPath],
        previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        let originalContext = super.invalidationContext(
            forInteractivelyMovingItems: targetIndexPaths,
            withTargetPosition: targetPosition,
            previousIndexPaths: previousIndexPaths,
            previousPosition: previousPosition)
        return cleanup(originalInvalidationContext: originalContext)
    }
    
    open override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        let originalContext = super.invalidationContextForEndingInteractiveMovementOfItems(
            toFinalIndexPaths: indexPaths,
            previousIndexPaths: previousIndexPaths,
            movementCancelled: movementCancelled)
        return cleanup(originalInvalidationContext: originalContext)
    }
}

/// A `UICollectionViewFlowLayout` subclass with interactive reordering implemented.
/// - Warning: All the `UICollectionViewFlowLayout` using interactive reordering should be
///     subclassed from `ListCollectionViewInteractiveReorderingLayout`
open class ListCollectionViewInteractiveReorderingFlowLayout:
    UICollectionViewFlowLayout,
    ListInteractiveReordering
{
    public weak var listAdapter: ListAdapter?
    
    open override func targetIndexPath(
        forInteractivelyMovingItem previousIndexPath: IndexPath,
        withPosition position: CGPoint) -> IndexPath {
        let originalTargetIndexPath = super.targetIndexPath(
            forInteractivelyMovingItem: previousIndexPath,
            withPosition: position)
        return targetIndexPath(
            forInteractivelyMovingItem: previousIndexPath,
            withPosition: position,
            originalTargetIndexPath: originalTargetIndexPath)
    }
    
    open override func invalidationContext(
        forInteractivelyMovingItems targetIndexPaths: [IndexPath],
        withTargetPosition targetPosition: CGPoint,
        previousIndexPaths: [IndexPath],
        previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        let originalContext = super.invalidationContext(
            forInteractivelyMovingItems: targetIndexPaths,
            withTargetPosition: targetPosition,
            previousIndexPaths: previousIndexPaths,
            previousPosition: previousPosition)
        return cleanup(originalInvalidationContext: originalContext)
    }
    
    open override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        let originalContext = super.invalidationContextForEndingInteractiveMovementOfItems(
            toFinalIndexPaths: indexPaths,
            previousIndexPaths: previousIndexPaths,
            movementCancelled: movementCancelled)
        return cleanup(originalInvalidationContext: originalContext)
    }
}

protocol ListInteractiveReordering {
    var listAdapter: ListAdapter? { get set }
    
    func targetIndexPath(
        forInteractivelyMovingItem previousIndexPath: IndexPath,
        withPosition position: CGPoint,
        originalTargetIndexPath: IndexPath) -> IndexPath
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        updatedTargetForInteractivelyMovingItem previousIndexPath: IndexPath,
        to originalTarget: IndexPath) -> IndexPath?
    
    func cleanup(
        originalInvalidationContext originalContext: UICollectionViewLayoutInvalidationContext
    ) -> UICollectionViewLayoutInvalidationContext
}

extension ListInteractiveReordering where Self: UICollectionViewLayout {
    func targetIndexPath(
        forInteractivelyMovingItem previousIndexPath: IndexPath,
        withPosition position: CGPoint,
        originalTargetIndexPath: IndexPath) -> IndexPath {
        if let listAdapter = self.listAdapter,
            let updatedTargetIndexPath = self.listAdapter(
                listAdapter,
                updatedTargetForInteractivelyMovingItem: previousIndexPath,
                to: originalTargetIndexPath){
            return updatedTargetIndexPath
        }
        return originalTargetIndexPath
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        updatedTargetForInteractivelyMovingItem previousIndexPath: IndexPath,
        to originalTarget: IndexPath) -> IndexPath? {
        let sourceSectionIndex = previousIndexPath.section
        var destinationSectionIndex = originalTarget.section
        var destinationItemIndex = originalTarget.item
        
        guard let sourceSectionController = listAdapter.sectionController(
                  forSection: sourceSectionIndex),
              let destinationSectionController = listAdapter.sectionController(
                  forSection: destinationSectionIndex),
            sourceSectionController.numberOfItems == 1,
            destinationSectionController.numberOfItems == 1,
            destinationItemIndex == 1
            else { return nil }
        
        // this is a reordering of sections themselves
        // the "item" representing our section was dropped into the end of a destination
        // section rather than the beginning so it really belongs one section after the
        // section where it landed
        if destinationSectionIndex < listAdapter.objects.count - 1 {
            destinationSectionIndex += 1
            destinationItemIndex = 0
        } else {
            // if we're moving an item to the last spot, our index would exceed the number
            // of sections available so we have to special case this scenario. iOS doesnt
            // allow an item move to "create" a new section
            listAdapter.isLastInteractiveMoveToLastSectionIndex = true
        }
        let updatedTarget = IndexPath(item: destinationItemIndex, section: destinationSectionIndex)
        return updatedTarget
    }
    
    func cleanup(
        originalInvalidationContext originalContext: UICollectionViewLayoutInvalidationContext
    ) -> UICollectionViewLayoutInvalidationContext {
        guard let listAdapter = self.listAdapter, let collectionView = self.collectionView else {
            return originalContext
        }
        let numberOfSections = listAdapter.numberOfSections(in: collectionView)
        
        // protect against invalidating an index path that no longer exists
        // (like item 1 in the last section after interactively reordering an item to the end of a
        // list of 1 item sections)
        guard var invalidatedItemIndexPaths = originalContext.invalidatedItemIndexPaths,
            let indexToRemove = invalidatedItemIndexPaths.index(
                where: { (indexPath) -> Bool in
                    if indexPath.section == numberOfSections - 1,
                       let sectionController = listAdapter.sectionController(
                           forSection: indexPath.section) {
                        return indexPath.item > sectionController.numberOfItems - 1
                    }
                    return false
            }) else { return originalContext }
        
        invalidatedItemIndexPaths.remove(at: indexToRemove)
        
        // FIXME: https://bugs.swift.org/browse/SR-7045
        var modifiedContext = UICollectionViewLayoutInvalidationContext()
        
        if let originalContext = originalContext
            as? UICollectionViewFlowLayoutInvalidationContext {
            let flowModifiedContext = UICollectionViewFlowLayoutInvalidationContext()
            flowModifiedContext.invalidateFlowLayoutDelegateMetrics =
                originalContext.invalidateFlowLayoutDelegateMetrics
            flowModifiedContext.invalidateFlowLayoutAttributes =
                originalContext.invalidateFlowLayoutAttributes
            modifiedContext = flowModifiedContext
        }
        
        modifiedContext.invalidateItems(at: invalidatedItemIndexPaths)
        if let invalidatedSupplementaryIndexPaths =
            originalContext.invalidatedSupplementaryIndexPaths {
            for (kind, indexPaths) in invalidatedSupplementaryIndexPaths {
                modifiedContext.invalidateSupplementaryElements(ofKind: kind, at: indexPaths)
            }
        }
        
        if let invalidatedDecorationIndexPaths = originalContext.invalidatedDecorationIndexPaths {
            for (kind, indexPaths) in invalidatedDecorationIndexPaths {
                modifiedContext.invalidateDecorationElements(ofKind: kind, at: indexPaths)
            }
        }
        modifiedContext.contentOffsetAdjustment = originalContext.contentOffsetAdjustment
        modifiedContext.contentSizeAdjustment = originalContext.contentSizeAdjustment
        return modifiedContext
    }
}

