# DottedLineView

[![CI Status](http://img.shields.io/travis/STAR-ZERO/DottedLineView.svg?style=flat)](https://travis-ci.org/STAR-ZERO/DottedLineView)
[![Version](https://img.shields.io/cocoapods/v/DottedLineView.svg?style=flat)](http://cocoapods.org/pods/DottedLineView)
[![License](https://img.shields.io/cocoapods/l/DottedLineView.svg?style=flat)](http://cocoapods.org/pods/DottedLineView)
[![Platform](https://img.shields.io/cocoapods/p/DottedLineView.svg?style=flat)](http://cocoapods.org/pods/DottedLineView)

Draw horizontal or vertical dotted line for iOS.

![screenshot](Screenshot/screenshot.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

### Interface Builder

Set `View` into Interface Builder

![interfacebuilder1](Screenshot/interfacebuilder1.png)

Set custome class

![interfacebuilder2](Screenshot/interfacebuilder2.png)

Edit properties

![interfacebuilder3](Screenshot/interfacebuilder3.png)

### Code

```swift
import DottedLineView
```

```swift
let dottedLineView = DottedLineView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 10))
dottedLineView.lineWidth = 8
dottedLineView.lineColor = UIColor.blueColor()
    
view.addSubview(dottedLineView)
```

## Requirements

* iOS 8.0+
* Xcode 7.3.1+

## Installation

DottedLineView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DottedLineView"
```

## Author

Kenji Abe, kenji@star-zero.com

## License

DottedLineView is available under the MIT license. See the LICENSE file for more info.
