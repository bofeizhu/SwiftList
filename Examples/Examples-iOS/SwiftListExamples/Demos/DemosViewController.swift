//
//  DemosViewController.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import SwiftList
import UIKit

final class DemosViewController: UIViewController, ListAdapterDataSource {
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
    let demos: [DemoItem] = [
        DemoItem(name: "Tail Loading", controllerClass: LoadMoreViewController.self),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demos"
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - ListAdapterDataSource
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable] {
        return demos.typeErased()
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable
    ) -> ListSectionController {
        return DemoSectionController()
    }
    
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
