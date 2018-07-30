# SwiftList

[![Build Status](https://travis-ci.com/zhubofei/SwiftList.svg?branch=master)](https://travis-ci.com/zhubofei/SwiftList)
[![Code Coverage](https://codecov.io/gh/zhubofei/SwiftList/branch/master/graph/badge.svg)](https://codecov.io/gh/zhubofei/SwiftList)

A data-driven `UICollectionView` framework for building fast and flexible lists.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
- [Credits](#credits)
- [License](#license)

## Features

|  | Main Features  |
---|-----------------
📵 | Never call `performBatchUpdates(_:completion:)` or `reloadData()` again
🏯 | Better architecture with reusable cells and components
🍱 | Create collections with multiple data types
👯‍♀️| Decoupled diffing algorithm
👩‍🔬| Fully unit tested
🎛 | Customize your diffing behavior for your models
🍫 | Simply `UICollectionView` at its core
🍢 | Extendable API
🐥 | Written in Swift

## Requirements

- Xcode 9.4+
- iOS 10.0+
- Swift 4.1+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `SwiftList` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftList'
end
```

Then, run the following command:

```bash
$ pod install
```

## Documentation

You can find [the docs here](https://zhubofei.github.io/SwiftList). Documentation is generated with [jazzy](https://github.com/realm/jazzy).

To regenerate docs, run `./scripts/build_docs.sh` from the root directory in the repo.

## Credits

`SwiftList` is forked from [`IGListKit`](https://github.com/Instagram/IGListKit) by [Instagram engineering](https://engineering.instagram.com/).

## License

`SwiftList` is [MIT-licensed](./LICENSE).

The files in the `/Examples/` directory are licensed under a separate license as specified in each file. Documentation is licensed [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
