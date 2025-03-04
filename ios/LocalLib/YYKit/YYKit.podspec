#
#  Be sure to run `pod spec lint YYkit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  
  spec.name         = "YYKit"
  spec.version      = "0.0.1"
  spec.summary      = "YYKit  iOS 17 适配版本"
  spec.platform     = :ios, "13.0"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.description      = <<-DESC
    TODO: YYKit V1.0.9 版本 iOS17 适配版本 本地库
                       DESC
  
  
  spec.homepage     = "http://www.guojiang.com/YYkit"
  spec.author       = { "AIRun" => "AIRun@guojiang.tv" }
  spec.source       = { :git => "http://www.guojiang.com/YYkit.git", :tag => "#{spec.version}" }
  
 
  spec.requires_arc = true
  spec.source_files  = "YYKit", "YYKit/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"
  spec.ios.vendored_frameworks = 'Vendor/WebP.framework'
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  
  non_arc_files = 'YYKit/Base/Foundation/NSObject+YYAddForARC.{h,m}', 'YYKit/Base/Foundation/NSThread+YYAdd.{h,m}'
  spec.ios.exclude_files = non_arc_files
  spec.subspec 'no-arc' do |sna|
     sna.requires_arc = false
     sna.source_files = non_arc_files
     end


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
