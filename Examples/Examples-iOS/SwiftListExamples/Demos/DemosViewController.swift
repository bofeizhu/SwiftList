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
}
