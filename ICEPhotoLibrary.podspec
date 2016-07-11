Pod::Spec.new do |s|
s.name             = 'ICEPhotoLibrary'
s.version          = '1.0.0'
s.summary          = '封装图片的存取功能'
s.description      = <<-DESC
TODO: 封装图片的存取功能,兼容iOS 7 (ALAsset) 和 iOS 8 (PHPhotoLibrary).
DESC

s.homepage         = 'https://github.com/My-Pod/ICEPhotoLibrary'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'gumengxiao' => 'rare_ice@163.com' }
s.source           = { :git => 'https://github.com/My-Pod/ICEPhotoLibrary.git', :tag => s.version.to_s }

s.ios.deployment_target = '7.0'

s.source_files = 'Classes/*.{h,m}'

end
