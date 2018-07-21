//
//  ListAdapter+UICollectionView.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/21/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension ListAdapter: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionMap.objects.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
}
