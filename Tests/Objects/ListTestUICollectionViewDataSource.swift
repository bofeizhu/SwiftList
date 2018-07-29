//
//  ListTestUICollectionViewDataSource.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/10/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

final class ListTestSectionObject {
    var objects: [AnyListDiffable] = []
    
    init(objects: [AnyListDiffable]) {
        self.objects = objects
    }
}

extension ListTestSectionObject: ListDiffable {
    var diffIdentifier: AnyHashable {
        return ObjectIdentifier(self)
    }
    
    static func == (lhs: ListTestSectionObject, rhs: ListTestSectionObject) -> Bool {
        if lhs === rhs {
            return true
        } else {
            return lhs.objects == rhs.objects
        }
    }
}

final class ListTestUICollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var sections: [ListTestSectionObject] = []
    
    init(collectionView: UICollectionView) {
        super.init()
        collectionView.dataSource = self
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return sections[section].objects.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}
