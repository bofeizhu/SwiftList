//
//  ListWorkingRangeHandler.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/20/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

final class ListWorkingRangeHandler {
    
    /// Initializes the working range handler.
    ///
    /// - Parameter workingRangeSize: workingRangeSize the number of sections beyond the visible
    ///     viewport that should be considered within the working range. Applies equally in both
    ///     directions above and below the viewport.
    init(workingRangeSize: Int) {
        self.workingRangeSize = workingRangeSize
    }
    
    /// Tells the handler that a cell will be displayed in the ListKit infra.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter managing the infra.
    ///   - indexPath: The index path of the cell in the `UICollectionView`.
    func listAdapter(
        _ listAdapter: ListAdapter,
        willDisplayItemAt indexPath: IndexPath) {
        visibleSectionIndices.insert(indexPath)
        updateWorkingRanges(with: listAdapter)
    }
    
    /// Tells the handler that a cell did end display in the ListKit infra.
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter managing the infra.
    ///   - indexPath: The index path of the cell in the UICollectionView.
    func listAdapter(
        _ listAdapter: ListAdapter,
        didEndDisplayingItemAt indexPath: IndexPath) {
        visibleSectionIndices.remove(indexPath)
        updateWorkingRanges(with: listAdapter)
    }
    
    // MARK: Private
    private var workingRangeSize: Int
    private var visibleSectionIndices: Set<IndexPath> = []
    private var workingRangeSectionControllers: Set<ListSectionController> = []
}

private extension ListWorkingRangeHandler {
    func updateWorkingRanges(with listAdapter: ListAdapter) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        // Swift doesn't have a native ordered set implementation yet. So we use set + sorting here
        // instead. And since we don't need to know the exact index of each section. We can achieve
        // the same O(nlogn) time complexity here.
        
        var visibleSectionSet: Set<Int> = []
        for indexPath in visibleSectionIndices {
            visibleSectionSet.insert(indexPath.section)
        }
        
        var start = 0
        var end = 0
        if visibleSectionSet.count > 0 {
            let visibleSections = visibleSectionSet.sorted()
            if let first = visibleSections.first {
                start = max(first - workingRangeSize, 0)
            }
            
            if let last = visibleSections.last {
                end = min(last + 1 + workingRangeSize, listAdapter.objects.count)
            }
            
        }
        
        // Build the current set of working range section controllers
        var workingRangeSectionControllers =
            Set<ListSectionController>.init(minimumCapacity: visibleSectionSet.count)
        
        for section in start..<end {
            if let object = listAdapter.object(for: section),
                let sectionController = listAdapter.sectionController(for: object) {
                workingRangeSectionControllers.insert(sectionController)
            }
        }
        
        assert(
            workingRangeSectionControllers.count < 1000,
            "This algorithm is way too slow with so many objects" +
                " \(workingRangeSectionControllers.count)")
        
        // Tell any new section controllers that they have entered the working range
        for sectionController in workingRangeSectionControllers {
            // Check if the item exists in the old working range item array.
            if !self.workingRangeSectionControllers.contains(sectionController) {
                // The section controller isn't in the existing list, so it's new.
                let workingRangeDelegate = sectionController.workingRangeDelegate
                workingRangeDelegate?.listAdapter(
                    listAdapter,
                    sectionControllerWillEnterWorkingRange: sectionController)
            }
        }
        
        // Tell any removed section controllers that they have exited the working range
        for sectionController in self.workingRangeSectionControllers {
            // Check if the item exists in the new list of section controllers
            if !workingRangeSectionControllers.contains(sectionController) {
                // If the item does not exist in the new list, then it's been removed.
                 let workingRangeDelegate = sectionController.workingRangeDelegate
                workingRangeDelegate?.listAdapter(
                    listAdapter,
                    sectionControllerDidExitWorkingRange: sectionController)
            }
        }
        
        self.workingRangeSectionControllers = workingRangeSectionControllers
    }
}
