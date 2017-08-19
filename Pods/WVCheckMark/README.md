# WVCheckMark
Animated checkmark made with CoreAnimation and Swift 3.0

![](https://github.com/wvabrinskas/WVCheckMark/blob/master/gif/out.gif)

# Installation
* Simply install using Cocoapods, add `'pod WVCheckMark'` to your podfile

# Usage
* `import WVCheckMark`
* WVCheckMark can be used with InterfaceBuilder. Just create a custom view and set the class to `WVCheckMark` and link to `@IBOutlet weak var check: WVCheckMark!`
* Run the checkmark `check.start()` or run the X `check.startX()`

# Functions
* `setColor(color: CGColor)` sets color of lines
* `setLineWidth(width: CGFloat)` sets width of the line
* `setDuration(speed: CGFloat)` sets the duration of circle animation
* `setDamping(damp: CGFloat)` sets the spring damping for the check or X animation
* `set(color:CGColor, width: CGFloat, damping: CGFloat, duration: CGFloat) ` sets all above parameters in one call
