//
//  ListTestScrollViewDelegate.swift
//  SwiftListTests
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

class ListTestScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var scrollViewDidScrollExpectation: XCTestExpectation?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollExpectation!.fulfill()
    }
}
