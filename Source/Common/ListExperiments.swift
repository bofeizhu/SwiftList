//
//  ListExperiments.swift
//  ListKit
//
//  Created by Bofei Zhu on 6/25/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

/**
 Bitmask-able options used for pre-release feature testing.
 */
struct ListExperiment: OptionSet {
    let rawValue: Int
    
    /// Specifies no experiments.
    static let listExperimentNone = ListExperiment(rawValue: 1 << 1)
    /// Test updater diffing performed on a background queue.
    static let listExperimentBackgroundDiffing = ListExperiment(rawValue: 1 << 2)
    /// Test fallback to reloadData when "too many" update operations.
    static let listExperimentReloadDataFallback = ListExperiment(rawValue: 1 << 3)
    /// Test a faster way to return visible section controllers.
    static let listExperimentFasterVisibleSectionController = ListExperiment(rawValue: 1 << 4)
    /// Test deduping item-level updates.
    static let listExperimentDedupeItemUpdates = ListExperiment(rawValue: 1 << 5)
    /// Test deferring object creation until just before diffing.
    static let listExperimentDeferredToObjectCreation = ListExperiment(rawValue: 1 << 6)
    /// Test getting collection view at update time.
    static let listExperimentGetCollectionViewAtUpdate = ListExperiment(rawValue: 1 << 7)
}

