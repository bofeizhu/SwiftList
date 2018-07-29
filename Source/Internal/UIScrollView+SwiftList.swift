//
//  UIScrollView+SwiftList.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/22/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

extension UIScrollView {
    var listContentInset: UIEdgeInsets {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return adjustedContentInset
        }
        return contentInset
    }
}
