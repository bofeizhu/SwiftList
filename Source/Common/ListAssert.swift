//
//  ListAssert.swift
//  ListKit
//
//  Created by Bofei Zhu on 7/4/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

func assertMainThread() {
    assert(Thread.isMainThread, "Must be on the main thread")
}
