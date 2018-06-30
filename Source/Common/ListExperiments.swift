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
public struct ListExperiment: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Specifies no experiments.
    public static let listExperimentNone = ListExperiment(rawValue: 1 << 1)
    /// Test updater diffing performed on a background queue.
    public static let listExperimentBackgroundDiffing = ListExperiment(rawValue: 1 << 2)
    /// Test fallback to reloadData when "too many" update operations.
    public static let listExperimentReloadDataFallback = ListExperiment(rawValue: 1 << 3)
    /// Test a faster way to return visible section controllers.
    public static let listExperimentFasterVisibleSectionController = ListExperiment(rawValue: 1 << 4)
    /// Test deduping item-level updates.
    public static let listExperimentDedupeItemUpdates = ListExperiment(rawValue: 1 << 5)
    /// Test deferring object creation until just before diffing.
    public static let listExperimentDeferredToObjectCreation = ListExperiment(rawValue: 1 << 6)
    /// Test getting collection view at update time.
    public static let listExperimentGetCollectionViewAtUpdate = ListExperiment(rawValue: 1 << 7)
}

