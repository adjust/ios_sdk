Pod::Spec.new do |s|
  s.name         = "AdjustIo"
  s.version      = "1.6"
  s.summary      = "This is the iOS SDK of AdjustIo. You can read more about it at http://adjust.io."
  s.homepage     = "http://adjust.io"
  s.license      = { :type => 'MIT', :file => 'MIT-LICENSE' }
  s.author       = { "Christian Wellenbrock" => "welle@adeven.com" }
  s.source       = { :git => "https://github.com/adeven/adjust_ios_sdk.git", :tag => "v1.6" }
  s.platform     = :ios, '5.0'
  s.source_files = 'AdjustIo/*.{h,m}', 'AdjustIo/AIAdditions/*.{h,m}'
  s.requires_arc = false
  s.dependency 'AFNetworking', '~> 1.2.1'
end
