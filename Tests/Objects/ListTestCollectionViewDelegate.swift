//
//  ListTestCollectionViewDelegate.swift
//  ListKitTests
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import ListKit

class ListTestCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    var scrollViewDidScrollExpectation: XCTestExpectation?
    var didEndDisplayingCellExpectation: XCTestExpectation?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollExpectation!.fulfill()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        didEndDisplayingCellExpectation!.fulfill()
    }
}

