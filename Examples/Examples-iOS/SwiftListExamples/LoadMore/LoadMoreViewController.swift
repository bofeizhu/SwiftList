//
//  LoadMoreViewController.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import UIKit
import SwiftList

final class LoadMoreViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var items = Array(0...20)
    var loading = false
    let spinToken = "spinner"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [AnyListDiffable] {
        let objects = items.typeErased()
        
//        if loading {
//            objects.append(AnyListDiffable(spinToken))
//        }
        
        return objects
    }
    
    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: AnyListDiffable) -> ListSectionController {
//        if let obj = object.base as? String, obj == spinToken {
//            return spinnerSectionController()
//        } else {
//            return LabelSectionController()
//        }
        return LabelSectionController()
    }
    
    func emptyBackgroundView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    // MARK: UIScrollViewDelegate
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
//                                   withVelocity velocity: CGPoint,
//                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
//        if !loading && distance < 200 {
//            loading = true
//            adapter.performUpdates(animated: true, completion: nil)
//            DispatchQueue.global(qos: .default).async {
//                // fake background loading task
//                sleep(2)
//                DispatchQueue.main.async {
//                    self.loading = false
//                    let itemCount = self.items.count
//                    self.items.append(contentsOf: Array(itemCount..<itemCount + 5))
//                    self.adapter.performUpdates(animated: true, completion: nil)
//                }
//            }
//        }
//    }
}
