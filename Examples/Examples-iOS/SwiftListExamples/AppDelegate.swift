//
//  AppDelegate.swift
//  SwiftListExamples
//
//  Created by Bofei Zhu on 7/28/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(
            rootViewController: DemosViewController())
        window?.makeKeyAndVisible()
        
        UICollectionView.appearance().backgroundColor = .white
        return true
    }

}

