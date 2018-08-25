//
//  ListTestAdapterHorizontalDataSource.swift
//  SwiftList
//
//  Created by Bofei Zhu on 8/8/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import XCTest
@testable import SwiftList

final class ListTestAdapterHorizontalDataSource: ListAdapterDataSource {
    var objects: [AnyListDiffable] = []
    var backgroundView: UIView = UIView()
    
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable] {
        return objects
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable
        ) -> ListSectionController? {
        if object.base is Int {
            return ListTestHorizontalSection()
        }
        return nil
    }
    
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView? {
        return backgroundView
    }
}
