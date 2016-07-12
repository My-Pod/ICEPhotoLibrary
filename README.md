# ICEPhotoLibrary



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ICEPhotoLibrary is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

## 版本记录
    1.0.0 基本功能
    1.0.1 修改:
        * 因 iOS8 下 PHPhotoLibrary 取图片时会多次回调结果, 依次返回缩略图和高清图.  现判断条件仅取高清图结果
        * 修复当图片或者地址为空时 carsh

```ruby
pod "ICEPhotoLibrary"
```

## Author

gumengxiao, rare_ice@163.com

## License

ICENewSecondPod is available under the MIT license. See the LICENSE file for more info.