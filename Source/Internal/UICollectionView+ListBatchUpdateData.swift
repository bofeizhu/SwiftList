//
//  UICollectionView+ListBatchUpdateData.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/3/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension UICollectionView {
    func apply(batchUpdateData data: ListBatchUpdateData) {
        deleteItems(at: data.deleteIndexPaths)
        insertItems(at: data.insertIndexPaths)

        for move in data.moveIndexPaths {
            moveItem(at: move.from, to: move.to)
        }

        for move in data.moveSections {
            moveSection(move.from, toSection: move.to)
        }

        deleteSections(data.deleteSections)
        insertSections(data.insertSections)
    }
}
