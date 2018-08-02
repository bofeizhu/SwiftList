//
//  ListTestCollectionViewDelegate.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListTestCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    var scrollViewDidScrollExpectation: XCTestExpectation?
    var didEndDisplayingCellExpectation: XCTestExpectation?
    var didSelectItemAtExpectation: XCTestExpectation?
    var willDisplayCellExpectation: XCTestExpectation?
    var didHighlightItemAtExpectation: XCTestExpectation?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollExpectation!.fulfill()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        didEndDisplayingCellExpectation!.fulfill()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        didSelectItemAtExpectation!.fulfill()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        willDisplayCellExpectation!.fulfill()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemAtExpectation!.fulfill()
    }
}

