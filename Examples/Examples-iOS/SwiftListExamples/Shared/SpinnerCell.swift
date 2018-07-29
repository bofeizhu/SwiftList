//
//  SpinnerCell.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/29/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import UIKit
import SwiftList

func spinnerSectionController() -> ListSingleSectionController {
    let configureClosure = { (item: Any, cell: UICollectionViewCell) in
        guard let cell = cell as? SpinnerCell else { return }
        cell.activityIndicator.startAnimating()
    }
    let sizeClosure = { (item: Any, context: ListCollectionContext?) -> CGSize in
        guard let context = context else { return .zero }
        return CGSize(width: context.containerSize.width, height: 100)
    }
    return ListSingleSectionController(
        cellClass: SpinnerCell.self,
        configureClosure: configureClosure,
        sizeClosure: sizeClosure)
}

final class SpinnerCell: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.contentView.addSubview(view)
        return view
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
